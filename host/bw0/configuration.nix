# bw1 is a router box
{ config, pkgs, lib, ... }:

let
  lpkgs = (import ../../pkgs {});
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    searchPath = [];
    nameservers4 = ["8.8.8.8"];
  };
  ucode = (pkgs.callPackage ../../base/default_ucode.nix {});
in {
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wl.nix
  ];


  ### Boot config
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix { structuredExtraConfig = (import ./kernel_conf.nix);});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    # loader.initScript.enable = true;
    initrd = {
      prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];
      luks.devices = [{
        name = "root";
        device = "/dev/disk/by-partlabel/bw0_r0_c";
        preLVM = true;
        fallbackToPassword = true;
        allowDiscards = true;
        keyFile = "/dev/disk/by-partlabel/bw0_key0";
        keyFileSize = 64;
      }];
      preFailCommands = ''${pkgs.bash}/bin/bash'';
      supportedFilesystems = ["btrfs"];
    };

    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/disk/by-id/usb-KINGSTON_SUV500MS240G_5002627783171569-0:0";
      fsIdentifier = "uuid";
      memtest86.enable = true;
      splashImage = null;
    };
  };
  ##### Host id stuff
  networking = {
    hostName = "bw0.ulwired-ctl.s.";
    hostId = "84d5fcc8";
    usePredictableInterfaceNames = false;
    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [
          { address = "10.19.4.1"; prefixLength = 24;}
        ];
        ipv6.addresses = [
          { address = "fd9d:1852:3555:1200::1"; prefixLength = 80;}
        ];
      };
      "eth_o4" = {
        ipv6.addresses = [
          { address = "fd9d:1852:3555:200:ff00::1"; prefixLength = 64;}
        ];
      };
      #useDHCP = false;
    };
    firewall.enable = false;
    useDHCP = false;

    defaultGateway = "10.19.4.2";
    #extraResolvconfConf = "resolv_conf=/etc/__resolvconf.out";
  } // dns.conf;

  systemd = {
    enableEmergencyMode = false;
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0c", KERNEL=="eth*", NAME="eth_wan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0d", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0e", KERNEL=="eth*", NAME="eth_o1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0f", KERNEL=="eth*", NAME="eth_o2"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:10", KERNEL=="eth*", NAME="eth_o3"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:11", KERNEL=="eth*", NAME="eth_o4"
  '';

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    nixBld

    openvpn
    iptables
    nftables
  ];

  sound.enable = false;
  security.polkit.enable = false;

  #environment.etc."resolv.conf" = dns.resolvConf;

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["noatime" "nodiratime" "space_cache" "autodefrag"];
    };
    "/boot" = { device = "/dev/disk/by-partlabel/bw0_b0"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Networking

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ []);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
