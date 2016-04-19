# Higurashi is a NixOS-based rescue system-on-a-usb-drive.
# This is its top-level configuration file.

{ _config, pkgs, lib, ... }:

let
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./kernel.nix
      ./boot.nix
      ../../base
      ../../base/site_stellvia.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_3;
  ##### Host id stuff
  networking = {
    hostName = "kokoro";
    hostId = "84d6fc00";
    nameservers = [ "10.16.0.1" ];
    search = [ "sh.s ulwifi.s baughn-sh.s" ];
    usePredictableInterfaceNames = false;
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
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:90:f5:d4:e4:dc", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with (vars.pkg pkgs); cliStd ++ nixBld ++ cliDbg ++ wifi ++ dev ++ video ++ audio ++ gui;

  services.xserver = {
    enable = true;
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    enableCtrlAltBackspace = true;
    exportConfiguration = true;
    synaptics = {
      enable = true;
    };
    videoDrivers = ["intel"];
  };

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };
  
  sound.enable = true;

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "kokoro_root"; options=btrfsOpts ++ ["ssd"]; };
  };

  ### Disable GRUB
  boot.loader.grub.enable = false;
  
  ### Networking
  networking.dhcpcd.allowInterfaces = [];

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  # Manually provided passwords are hashed empty strings.
  users = (slib.mkUserGroups (vars.userSpecs ++ [
    ["prsw" 1001 ["nix-users", "audio", "video"] []]
  ]));

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";
}
