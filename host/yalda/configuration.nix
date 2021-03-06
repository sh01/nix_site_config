# Yalda is a desktop deployment with a focus on games.

{ config, pkgs, lib, ... }:

let
  inherit (pkgs) callPackage;
  ssh_pub = (import ../../base/ssh_pub.nix).yalda;
  cont = callPackage ../../containers {};
  contBase = cont.termC ssh_pub;
  nft = callPackage ../../base/nft.nix {};
  lpkgs = (import ../../pkgs {});
  ucode = (pkgs.callPackage ../../base/default_ucode.nix {});
in rec {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/term/desktop.nix
    ../../base/site_wl.nix
  ];

  #boot.kernelPackages = pkgs.linuxPackages_4_11;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix);});
  boot.initrd.prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];
  environment.systemPackages = with (callPackage ../../pkgs/pkgs/meta {}); with lpkgs; [
    games
    SH_dep_mc0
    SH_dep_factorio
    SH_dep_CK2
    SH_dep_WL2
    SH_dep_Stellaris
    SH_dep_gbase
    SH_dep_ggame
    SH_dep_ggame32
  ];
  
  containers = contBase;
  programs.ssh.extraConfig = cont.sshConfig;
    
  ##### Host id stuff
  networking = {
    hostName = "yalda";
    hostId = "84d6fc01";
    iproute2 = vars.iproute2;
    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [{
          address = "10.16.0.65";
          prefixLength = 24;
        }];
        ipv4.routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.16.0.1";
        }];
        ipv6.addresses = [
          { address = "2001:470:7af3:1:1:0:2:1"; prefixLength = 80;}
          { address = "fd9d:1852:3555:0200::41"; prefixLength = 56;}
        ];
        ipv6.routes = [
          { address = "fd9d:1852:3555::"; prefixLength = 48; via = "fd9d:1852:3555:200::1";}
          { address = "::"; prefixLength = 0; via = "2001:470:7af3:1:1::1";}
        ];
      };
    };
    firewall.enable = false;
    dhcpcd.allowInterfaces = [];
    dhcpcd.enable = false;
    nameservers = ["10.16.0.1"];
  };

  systemd = {
    services = {
      SH_mount_ys = {
        partOf = ["multi-user.target"];
        wantedBy = ["SH_containers_sh.service"];
        description = "SH_mount_ys";
        path = with pkgs; [coreutils eject lvm2 kmod cryptsetup utillinux];
        script = ''
mountpoint -q /mnt/ys && exit 0
# Set up /mnt/ys
dmsetup mknodes
modprobe bcache

test -e /dev/mapper/ys2 || cryptsetup luksOpen --key-file=/var/crypt/ys0 /dev/md/yalda_ys1 ys1
for disk in /dev/mapper/ys1 /dev/mapper/root_base0p2; {
  # Already registered disks will throw errors; ignore those
  echo $disk > /sys/fs/bcache/register || true
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
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="04:d4:c4:57:f9:da", KERNEL=="eth*", NAME="eth_lan"
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
  services.xserver.videoDrivers = ["intel" "ati" "amdgpu"];


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
