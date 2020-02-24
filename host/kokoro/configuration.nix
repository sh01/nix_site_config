# Kokoro is an experimental desktop deployment.

{ _config, pkgs, lib, ... }:

let
  inherit (pkgs) callPackage lib;
  ssh_pub = (import ../../base/ssh_pub.nix).kokoro;
  cont = callPackage ../../containers {};
in {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term
    ../../base/site_stellvia.nix
  ];

  containers = (cont.termC ssh_pub);
  systemd.services = cont.termS;
  
  ##### Host id stuff
  networking = {
    hostName = "kokoro";
    hostId = "84d6fc00";
    iproute2 = vars.iproute2;
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.129";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "2a00:15b8:109:1:1:0:1:1";
          prefixLength = 80;
        }];
      };
    };
    dhcpcd.allowInterfaces = [];
    networkmanager = {
      enable = true;
    };
    localCommands = ''
PATH=/run/current-system/sw/bin/
rmmod iwlwifi || exit 0
echo -n /run/current-system/firmware/ > /sys/module/firmware_class/parameters/path
modprobe iwlwifi
'';
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:90:f5:d4:e4:dc", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="88:53:2e:f2:e5:95", KERNEL=="wlan*", NAME="eth_wifi"
  '';

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "kokoro_root"; options=btrfsOpts ++ ["ssd"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";
}
