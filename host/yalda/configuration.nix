# Yalda is a desktop deployment with a focus on games.

{ config, pkgs, lib, ... }:

let
  inherit (pkgs) callPackage;
  ssh_pub = (import ../../base/ssh_pub.nix).yalda;
  cont = callPackage ../../containers {};
  contBase = cont.termC ssh_pub;
  nft = callPackage ../../base/nft.nix {};
  lpkgs = (import ../../pkgs {});
in rec {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term
    ../../base/site_stellvia.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_4_4;
  environment.systemPackages = with (callPackage ../../pkgs/pkgs/meta {}); with lpkgs; [
    games
    SH_dep_mc0
    SH_dep_factorio
    SH_dep_KSP
    SH_dep_CK2
    SH_dep_WL2
    SH_dep_Stellaris
    SH_dep_ggame
    SH_dep_ggame32
  ];
  
  containers = contBase;
  programs.ssh.extraConfig = cont.sshConfig;
    
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
        ip6 = [
	{ address = "2001:470:7af3:1:1:0:2:1";
          prefixLength = 80; }
	{ address = "fd9d:1852:3555:0200::41";
	  prefixLength = 56;
	}
	];
      };
    };
    firewall.enable = false;
    dhcpcd.allowInterfaces = [];
    localCommands = ''
ip route replace default via 10.16.0.1 || true
ip -6 route replace fd9d:1852:3555::/48 via fd9d:1852:3555:200::1 || true
ip -6 route replace default via 2001:470:7af3:1:1::1 || true
'';
    nameservers = ["10.16.0.1"];
  };

  systemd = {
    services = {
      SH_mount_ys = {
        partOf = ["multi-user.target"];
        wantedBy = ["SH_containers_sh.service"];
        description = "SH_mount_ys";
        path = with pkgs; [coreutils eject lvm2 kmod cryptsetup];
        script = ''
mountpoint -q /mnt/ys && exit 0
# Set up /mnt/ys
dmsetup mknodes
modprobe bcache

cryptsetup luksOpen --key-file=/var/crypt/ys0 /dev/md/yalda_ys1 ys1
for disk in /dev/mapper/ys1 /dev/mapper/root_base0p2; {
  echo $disk > /sys/fs/bcache/register
}
sleep 2 # wait for kernel to link disk label
mount /mnt/ys
'';
      };
    } // cont.termS // nft.services;
    enableEmergencyMode = false;
  };
  
  environment.etc = nft.conf_terminal;

  services.udev = {
    extraRules = ''
      # Name network devices statically based on MAC address
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="74:d0:2b:2b:7c:7f", KERNEL=="eth*", NAME="eth_lan"
    '';
  };

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache" "autodefrag"];
  in {
    "/" = { label = "yalda_root"; options=btrfsOpts ++ ["ssd"]; };
    "/mnt/ys" = { label = "ys0b"; options=btrfsOpts ++ ["noauto"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  services.xserver.videoDrivers = ["intel" "ati"];


#  services.charybdis = {
#    enable = true;
#    motd = ''foo
#bar
#
#quux'';
#    config = "";
#  };
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
