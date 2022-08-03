# nova is a small entertainment system
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = (pkgs.callPackage ../../lib {});
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["10.17.1.1" "::1"];
  };
  nft = pkgs.callPackage ../../base/nft.nix {};
in {
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/site_wi.nix
    ../../fix/19_9.nix
    ../../base/ntp_client_default.nix
    (import ../../base/std_efi_boot.nix {inherit pkgs; structuredExtraConfig = (import ../bw0/kernel_conf.nix {inherit lib;});})
  ];

  ### Boot config
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-partlabel/nova_vg0";
    keyFile = "/dev/disk/by-partlabel/nova_key0";
  };

  ### Networking
  networking = {
    hostName = "nova";
    hostId = "84d5fccc";
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = false;

    interfaces = {
      "eth0" = {
        ipv4.addresses = [
          { address = "10.17.1.71"; prefixLength = 24; }
          { address = "10.17.3.5"; prefixLength = 24; }
        ];
        ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::47"; prefixLength=64;}];
      };
    };
    # Push this way out of the way.
    resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";

    nftables = {
      enable = true;
      rulesetFile = builtins.toFile "rules.nft" nft.conf_terminal;
    };
  };
  environment.etc."resolv.conf" = dns.resolvConf;
  #services.udev.extraRules = (builtins.readFile ./udev.rules);

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    moreutils
    nixBld

    openvpn
    iptables
    radvd
    nftables

    # direct packages
    prometheus
    uptimed

    #gui
  ];

  sound.enable = true;
  security.polkit.enable = true;

  fileSystems = {
    "/".device = "/dev/mapper/nova0-main";
    "/boot" = { device = "/dev/disk/by-partlabel/nova_EFI_sys"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services = {
    openssh.moduliFile = ./sshd_moduli;
    prometheus.exporters.node = (import ../../base/node_exporter.nix);
    udisks2.enable = false;
    uptimed.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        job.execCmd = "/run/current-system/sw/bin/Xorg -config /etc/X11/xorg.conf -verbose 3 -auth /var/local/x11/xauth_0";
      };
      extraConfig = mkForce ''
Section "ServerFlags"
        Option "AutoEnableDevices" "false"
        Option "AutoAddDevices" "false"
EndSection
'';
    };
  };
  systemd.services.display-manager.enable = mkForce true;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [stash]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
}
