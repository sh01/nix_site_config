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

  ##### Host id stuff
  networking = {
    hostName = "keiko.sh.s";
    hostId = "84d5fcc6";
    usePredictableInterfaceNames = false;
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.2";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "2a00:15b8:109:1:1::2";
          prefixLength = 80;
        }
	{ address = "fd9d:1852:3555:0200::2";
	  prefixLength = 56;
	}
	];
      };
    };
    localCommands = ''
ip route replace default via 10.16.0.1 || true
ip -6 route replace fd9d:1852:3555::/48 via fd9d:1852:3555:200::1 || true
ip -6 route replace default via 2a00:15b8:109:1:1::1 || true
'';
    firewall.enable = false;
    useDHCP = false;
    dhcpcd.allowInterfaces = [];

    #defaultGateway = "10.16.0.1";
    extraResolvconfConf = "resolv_conf=/etc/__resolvconf.out";
  } // dns.conf;

  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="14:da:e9:92:4a:ae", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:1e:67:df:b2:64", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="40:8d:5c:cd:ec:59", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [base cliStd nixBld];

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
    "/mnt/a2" = { device = "/dev/mapper/a2"; options = btrfsOptsNA; };
  };

  ### Boot config
  # boot.loader.initScript.enable = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_4_4;
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    initrd.luks.devices = [{
      name = "luksVg0";
      device = "/dev/disk/by-partlabel/keiko_vg0";
      preLVM = true;
      keyFile = "/dev/disk/by-partlabel/keiko_key1";
      keyFileSize = 64;
    }];
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

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; [sh cc sh_yalda es_github]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
