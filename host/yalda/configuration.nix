# Yalda is a desktop deployment with a focus on games.

{ _config, pkgs, lib, ... }:

let
  ssh_pub = (import ../../base/ssh_pub.nix).yalda;
in {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term
    ../../base/site_stellvia.nix
  ];
 
  containers = ((import ../../containers).termC ssh_pub);
  
  ##### Host id stuff
  networking = {
    hostName = "yalda";
    hostId = "84d6fc01";
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.65";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "2a00:15b8:109:1:1:0:2:1";
          prefixLength = 80;
        }];
      };
    };
    dhcpcd.allowInterfaces = [];
  };

  systemd = {
    services.SH_local_setup = {
      after = ["-.mount"];
      description = "SH_local_setup";
      script = ''
# FIXME: Clean the CS path use up.
PATH=/run/current-system/sw/bin/

# Set up /mnt/ys
dmsetup mknodes
modprobe bcache

cryptsetup luksOpen --key-file=/var/crypt/ys0 /dev/md/yalda_ys1 ys1
for disk in /dev/mapper/ys1 /dev/mapper/root_base0p2; do echo $disk > /sys/fs/bcache/register; done
mount /mnt/ys

# Set up container dirs
mkdir -p /run/users/sh
chown sh:sh /run/users/sh
'';
    };
    enableEmergencyMode = false;
  };
    
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="74:d0:2b:2b:7c:7f", KERNEL=="eth*", NAME="eth_lan"
  '';

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "yalda_root"; options=btrfsOpts ++ ["ssd"]; };
    "/mnt/ys" = { label = "ys0b"; options=btrfsOpts ++ ["noauto"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
