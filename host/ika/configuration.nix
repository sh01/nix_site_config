# Ika is a small traffic-routing cloud deployment.
# Manual setup things:
#  /var/spool . go+rx (uptimed)
#  /var/local/run/openvpn openvpn:openvpn

{ config, pkgs, ... }:
let
  lpkgs = (import ../../pkgs {});
  slib = import ../../lib;
  ssh_pub = import ../../base/ssh_pub.nix;
  vars = import ../../base/vars.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ./nixos-in-place.nix
    ../../base
    ../../base/nox.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking = {
    hostName = "ika";
    hostId = "84d5fcc9";
    useDHCP = false;
    firewall.enable = false;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="6a:8b:f8:44:c1:44", KERNEL=="eth*", NAME="eth0"
  '';

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); with lpkgs; [
    base
    cliStd
    nixBld
    SH_sys_scripts
    uptimed
  ];

  sound.enable = false;
  security.polkit.enable = false;

  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  services.openvpn.servers = {
    vpn-ocean = {
      config = (pkgs.callPackage ./vpn-ocean.nix {lpkgs = lpkgs;});
    };
  };
  services.uptimed.enable = true;

  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [openvpn]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
