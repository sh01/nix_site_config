# Keiko is a storage system.
{ config, pkgs, lib, ... }:

let
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {};
in {
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_stellvia.nix
  ];


  ### Boot config
  boot = {
    kernelPackages = pkgs.linuxPackages_4_4;
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    # loader.initScript.enable = true;
    initrd.luks.devices = [ {
      name = "luksVg0";
      device = "/dev/sdb3";
      preLVM = true;
    }];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
      fsIdentifier = "label";
      memtest86.enable = true;
      splashImage = null;
    };
  };
  ##### Host id stuff
  networking = {
    hostName = "likol.sh.s";
    hostId = "84d5fcc8";
    usePredictableInterfaceNames = false;
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.3";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "2a00:15b8:109:1:1::3";
          prefixLength = 80;
        }];
      };
    };
    firewall.enable = false;
    useDHCP = false;
    dhcpcd.allowInterfaces = [];

    defaultGateway = "10.16.0.1";
    extraResolvconfConf = "resolv_conf=/etc/__resolvconf.out";
  } // dns.conf;

  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:90:f5:d4:e4:dc", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [base cliStd nixBld];

  sound.enable = false;
  security.polkit.enable = false;

  environment.etc = {
    "resolv.conf" = dns.resolvConf;
  };

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/vg0/root";
      fsType = "btrfs";
    };
  };

  ### Networking

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [cc sh_yalda es_github]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
