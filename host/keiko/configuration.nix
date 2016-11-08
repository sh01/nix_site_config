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

  boot.kernelPackages = pkgs.linuxPackages_4_4;
  boot.blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
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
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="14:da:e9:92:4a:ae", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:1e:67:df:b2:64", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="40:8d:5c:cd:ec:59", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [base cliStd nixBld];

  sound.enable = false;
  security.polkit.enable = false;

  environment.etc = {
    "crypttab" = {
      text = ''
# <target name> <source device>         <key file>      <options>
a0      /dev/md/a0      /var/crypt/a0_2 noauto,luks
a1      /dev/md/a1      /var/crypt/a1_0 noauto,luks
#a2     /dev/md/a2      /var/crypt/a2_0 noauto,luks
a2      /dev/md/a2      none            noauto,luks
'';
    };
    "resolv.conf" = dns.resolvConf;
  };

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
    btrfsOptsNA = btrfsOpts ++  ["noauto"];
  in {
    "/" = { label = "keiko_root"; options=btrfsOpts; };
    "/boot" = { device = "UUID=5e608f7c-d2ae-41f9-a14d-a81820d50122"; options=["noauto"] ++ baseOpts; };
    "/mnt/a0" = { device = "/dev/mapper/a0"; options = btrfsOptsNA; };
    "/mnt/a1" = { device = "/dev/mapper/a1"; options = btrfsOptsNA; };
    "/mnt/a2" = { device = "/dev/mapper/a2"; options = btrfsOptsNA; };
  };

  ### Boot config
  # boot.loader.initScript.enable = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    fsIdentifier = "label";
    memtest86.enable = true;
    splashImage = null;
  };

  ### Networking

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [cc sh_yalda]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
