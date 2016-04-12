# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./kernel.nix
      ../../base
      ../../base/nox.nix
      ../../base/site_stellvia.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_3;
  boot.blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek"];
  ##### Host id stuff
  networking = {
    hostName = "keiko.sh.s";
    hostId = "84d5fcc6";
    nameservers = [ "10.16.0.1" ];
    search = [ "sh.s ulwifi.s baughn-sh.s" ];
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
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="14:da:e9:92:4a:ae", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = vars.pkCLIStd;

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
  };

  fileSystems = let
    baseOpts = "noatime,nodiratime";
    btrfsOpts = baseOpts + ",space_cache,autodefrag";
    btrfsOptsNA = btrfsOpts + ",noauto";
  in {
    "/" = { label = "keiko_root"; options=btrfsOpts; };
    "/boot" = { device = "UUID=5e608f7c-d2ae-41f9-a14d-a81820d50122"; options="noauto," + baseOpts; };
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
  networking.useDHCP = false;
  networking.dhcpcd.allowInterfaces = [];

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (vars.userSpecs ++ [
      ["cc" 1005 [] []]
      ["sh_yalda" 1006 [] [ssh_pub.sh_allison ssh_pub.sh_yalda]]
  ]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
