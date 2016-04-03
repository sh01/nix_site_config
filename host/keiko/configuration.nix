# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  mkMerge = lib.mkMerge;
  elemAt = builtins.elemAt;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../base
    ];

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

  ### Package auth
  nix.binaryCachePublicKeys = [];
  nix.binaryCaches = [];
  
  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };

  # Set your time zone.
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

    btrfsProgs
    cryptsetup

    manpages
    man_db
    posix_man_pages

    git
    gitAndTools.git-annex
    gnupg
    mdadm
  ];
  nixpkgs.config.allowUnfree = false;
  nixpkgs.config.x11Support = false;
  nixpkgs.config.graphical = false;

  fileSystems = let
    baseOpts = "noatime,nodiratime";
    btrfsOpts = baseOpts + ",space_cache,autodefrag";
    btrfsOptsNA = btrfsOpts + ",noauto";
  in {
    "/" = { label = "root"; options=btrfsOpts; };
    "/boot" = { device = "UUID=5e608f7c-d2ae-41f9-a14d-a81820d50122"; options=baseOpts; };
    "/mnt/a0" = { device = "/dev/mapper/a0"; options = btrfsOptsNA; };
    "/mnt/a1" = { device = "/dev/mapper/a1"; options = btrfsOptsNA; };
    "/mnt/a2" = { device = "/dev/mapper/a2"; options = btrfsOptsNA; };
  };

  fonts.fontconfig.enable = false;

  ### Boot config
  boot.loader.grub.enable = false;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda";
  boot.loader.initScript.enable = true;

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

  ### Per-program config
  programs.ssh.startAgent = false;
  programs.zsh = {
    enable = true;
  };

  ### User / Group config
  # Define paired user/group accounts.
  users = let
    userSpecs = [
      ["sh" 1000 ["nix-users"]]
      ["cc" 1005 []]
      ["sh_yalda" 1006 []]
      ["sh_allison" 1007 []]
    ];
  in {
    groups = mkMerge (
      (map (s: let U = elemAt s 0; in { "${U}" = { name = U; gid = (elemAt s 1); }; }) userSpecs) ++ [
      {"nix-users" = { gid = 2049; }; }
      ]);
    users = mkMerge (map (s: let U = elemAt s 0; in { "${U}" = { name = U; uid = (elemAt s 1); group = U; extraGroups = (elemAt s 2); isNormalUser = true; }; }) userSpecs);
    defaultUserShell = "/run/current-system/sw/bin/zsh";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  ### terminal stuff
  fonts.fontconfig.defaultFonts.serif = [ "DejaVu Sans" ];

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
