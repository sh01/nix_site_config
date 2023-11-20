# Keiko is a storage system.
{ config, pkgs, lib, ... }:

let
  inherit (pkgs) callPackage;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = callPackage ../../lib {};
  vars = callPackage ../../base/vars.nix {};
  dns = (import ../../base/dns.nix) {};
in {
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wi.nix
    ../../fix/19_9.nix
    ../../base/ntp_client_default.nix
  ];

  #environment.etc."nix/nix.conf".source = mkForce (builtins.readFile ../../base/nix.conf);
  ##### Host id stuff
  networking = {
    hostName = "keiko";
    hostId = "84d5fcc6";
    usePredictableInterfaceNames = false;
    iproute2 = vars.iproute2;
    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [
          {address = "10.17.1.11"; prefixLength = 24;}
        ];
        ipv4.routes = [
          {address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1";}
        ];
        ipv6.addresses = [
          { address = "2001:470:7af3:1:1::2"; prefixLength = 80;}
          { address = "fd9d:1852:3555:0200::2"; prefixLength = 56;}
        ];
        ipv6.routes = [
          { address = "fd9d:1852:3555::"; prefixLength = 48; via = "fd9d:1852:3555:200::1";}
          { address = "::"; prefixLength = 0; via = "2001:470:7af3:1:1::1";}
        ];
      tempAddress = "disabled";
      };
    };
    firewall.enable = false;
    useDHCP = false;
    dhcpcd.allowInterfaces = [];
    useNetworkd = false;

    resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";

    nftables = {
      enable = true;
      rulesetFile = ./nft.conf;
    };
    
  } // dns.conf;

  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="14:da:e9:92:4a:ae", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:1e:67:df:b2:64", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="40:8d:5c:cd:ec:59", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    nixBld
    uptimed
  ];

  sound.enable = false;
  security.polkit.enable = false;

  environment.etc."resolv.conf" = dns.resolvConf;

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
    btrfsOptsNA = btrfsOpts ++  ["noauto"];
  in {
    "/" = { label = "keiko_root1"; options=btrfsOpts; };
    "/boot" = { label = "keiko_boot1"; options=["noauto"] ++ baseOpts; };
    "/mnt/a0" = { device = "/dev/mapper/a0"; options = btrfsOptsNA; };
    "/mnt/a1" = { device = "/dev/mapper/a1"; options = btrfsOptsNA; };
    "/mnt/a7" = { device = "/dev/mapper/a7"; options = btrfsOptsNA; };
  };

  services.multipath = let
    no = "no";
  in {
    enable = true;
    pathGroups = [];
    defaults = ''
      skip_kpartx no
      path_grouping_policy multibus
'';
  };
  
  ### Boot config
  # boot.loader.initScript.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix {inherit lib;});});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    initrd = {
      luks.devices = {
        "luksVg0" = {
          device = "/dev/disk/by-partlabel/keiko_vg0";
          preLVM = true;
          #keyFile = "/dev/disk/by-partlabel/keiko_key1";
          #keyFileSize = 64;
        };
      };
      preFailCommands = ''${pkgs.bash}/bin/bash'';
      supportedFilesystems = ["btrfs"];
    };
    supportedFilesystems = ["btrfs"];
    loader.grub = {
      enable = true;
      version = 2;
      #device = "/dev/disk/by-id/usb-SanDisk_Cruzer_Blade_4C532000070826116035-0:0";
      device = "/dev/disk/by-id/ata-WDC_WD60EFRX-68L0BN1_WD-WX11DB56ZPT9";
      fsIdentifier = "label";
      memtest86.enable = true;
      splashImage = null;
    };
  };
  
  ### Networking

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;
  services.uptimed.enable = true;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [
    sh cc es_github mail-sh
    sh_yalda
  ]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
