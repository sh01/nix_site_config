# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  mkMerge = lib.mkMerge;
  elemAt = builtins.elemAt;
  ssh_pub = import ../../base/ssh_pub.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./kernel.nix
      ../../base
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_3;
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

  ##### Package auth
  nix.binaryCachePublicKeys = [];
  nix.binaryCaches = [];
  
  ##### Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };

  #### Set time zone.
  time.timeZone = "Europe/Dublin";

  environment.shells = [ "/run/current-system/sw/bin/zsh" ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    glibcLocales

    file
    less
    most
    lsof
    screen
    tree
    zsh

    gzip
    bzip2
    xz
 
    python
    python3

    iputils
    netcat
    socat
    tcpdump
    wget

    mdadm
    btrfsProgs
    cryptsetup
    smartmontools

    nix-repl

    manpages
    man_db
    posix_man_pages

    git
    gitAndTools.git-annex
    gnupg
  ];
  nixpkgs.config.allowUnfree = false;
  nixpkgs.config.x11Support = false;
  nixpkgs.config.graphical = false;

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

  fonts.fontconfig.enable = false;

  ### Boot config
  # boot.loader.initScript.enable = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    fsIdentifier = "uuid";
    memtest86.enable = true;
    splashImage = null;
  };

  ### Networking
  networking.useDHCP = false;
  networking.dhcpcd.allowInterfaces = [];
  networking.firewall.allowPing = true;
  networking.firewall.rejectPackets = true;

  nix.allowedUsers = [ "@nix-users" ];

  ### Nix build config
  nix.daemonIONiceLevel = 2;
  nix.daemonNiceLevel = 2;
  nix.requireSignedBinaryCaches = true;

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### Per-program config
  programs.ssh.startAgent = false;
  programs.ssh.knownHosts = ssh_pub.knownHosts;

  programs.zsh = {
    enable = true;
  };

  ### User / Group config
  # Define paired user/group accounts.
  users = let
    userSpecs = [
      ["sh" 1000 ["wheel" "nix-users"] [ssh_pub.sh_allison]]
      ["cc" 1005 [] []]
      ["sh_yalda" 1006 [] [ssh_pub.sh_allison ssh_pub.sh_yalda]]
      ["backup-client" 1002 [] [ssh_pub.root_keiko]]
    ];
  in {
    groups = mkMerge (
      (map (s: let U = elemAt s 0; in { "${U}" = { name = U; gid = (elemAt s 1); }; }) userSpecs) ++ [
      {"nix-users" = { gid = 2049; }; }
      ]);
    users = mkMerge (map (s: let U = elemAt s 0; in { "${U}" = { name = U; uid = (elemAt s 1); group = U; extraGroups = (elemAt s 2); openssh.authorizedKeys.keys = (elemAt s 3); isNormalUser = true; }; }) userSpecs);
    defaultUserShell = "/run/current-system/sw/bin/zsh";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  ### terminal stuff
  fonts.fontconfig.defaultFonts.serif = [ "DejaVu Sans" ];

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
