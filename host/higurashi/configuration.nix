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
      ../../base/nox.nix
      ../../base/site_stellvia.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_3;
  ##### Host id stuff
  networking = {
    hostName = "higurashi";
    hostId = "85d5fcc6";
    # nameservers = [ "10.16.0.1" ];
    # search = [ "sh.s ulwifi.s baughn-sh.s" ];
    usePredictableInterfaceNames = false;
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="14:da:e9:92:4a:ae", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="74:d0:2b:2b:7c:7f", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", AATR{address}=="54:ee:75:04:0e:ae", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = vars.pkCLIStd ++ vars.pkCLIDbg ++ vars.pkWifi;

  sound.enable = false;
  security.polkit.enable = false;

  fileSystems = let
    baseOpts = "noatime,nodiratime";
    btrfsOpts = baseOpts + ",space_cache,autodefrag";
  in {
    "/" = { label = "higurashi_root"; options=btrfsOpts; };
  };

  ### Disable GRUB
  boot.loader.grub.enable = false;
  
  ### Networking
  networking.dhcpcd.allowInterfaces = [];

  ### Services
  services.openssh.enable = false;
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (vars.userSpecs ++ [
  ]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";
}
