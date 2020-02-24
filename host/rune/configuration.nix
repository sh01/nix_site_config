# Rune is a trusted-terminal deployment.

{ pkgs, ... }:

let
  inherit (pkgs) callPackage lib;
  ssh_pub = (import ../../base/ssh_pub.nix).rune;
  cont = callPackage ../../containers {};
  nft = callPackage ../../base/nft.nix {};
  route = callPackage ../../base/route.nix {};
  ucode = (pkgs.callPackage ../../base/default_ucode.nix {});
in rec {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term
    ../../base/site_wl.nix
  ];

  containers = (cont.termC ssh_pub);
  systemd.services = cont.termS // nft.services // route.services;
  programs.ssh.extraConfig = cont.sshConfig;
  environment.etc = nft.conf_terminal;

  boot = {
    initrd.prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix { structuredExtraConfig = (import ./kernel_conf.nix);});
  };
    
  ##### Host id stuff
  networking = {
    hostName = "rune";
    hostId = "84d6fc02";
    iproute2 = vars.iproute2;
    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [{
          address = "10.16.0.136";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "2001:470:7af3:1:1:0:1:5";
          prefixLength = 80;
        }];
      };
    };
    dhcpcd.allowInterfaces = ["eth_wifi"];
    networkmanager = {
      enable = true;
      unmanaged = ["eth_lan"];
    };
    localCommands = ''
PATH=/run/current-system/sw/bin/
rmmod iwlwifi || exit 0
echo -n /run/current-system/firmware/ > /sys/module/firmware_class/parameters/path
modprobe iwlwifi
'';
    firewall.enable = false;
  };
  
  # Name network devices statically based on MAC address
  # Make blink1 devices usable by sh and friends.
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="b8:88:e3:f5:24:ce", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:6c:66:51:61:34", KERNEL=="wlan*", NAME="eth_wifi"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27b8", ATTRS{idProduct}=="01ed", MODE:="660", GROUP="video"
  '';

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "rune_root"; options=btrfsOpts ++ ["nossd"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  services.openvpn.servers = {
    msvpn_client = {
      config = lib.readFile ./vpn/memespace;
    };
  };
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
