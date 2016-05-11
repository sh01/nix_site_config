# Kokoro is an experimental desktop deployment.

{ pkgs, ... }:

let
  inherit (pkgs) callPackage lib;
  ssh_pub = (import ../../base/ssh_pub.nix).rune;
  cont = callPackage ../../containers {};
in {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term
    ../../base/site_stellvia.nix
  ];
 
  containers = (cont.termC ssh_pub);
  systemd.services = cont.termS;
  programs.ssh.extraConfig = cont.sshConfig;
  
  ##### Host id stuff
  networking = {
    hostName = "rune";
    hostId = "84d6fc02";
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.136";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "2a00:15b8:109:1:1:0:1:5";
          prefixLength = 80;
        }];
      };
    };
    dhcpcd.allowInterfaces = ["eth_wifi"];
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="b8:88:e3:f5:24:ce", KERNEL=="eth*", NAME="eth_lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:6c:66:51:61:34", KERNEL=="wlan*", NAME="eth_wifi"
  '';

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "rune_root"; options=btrfsOpts ++ ["nossd"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  services.openvpn.servers = {
    msvpn_client = {
      config = lib.readFile ./vpn/memespace;
    };
  };
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
