# Yalda is a desktop deployment with a focus on games.
{ config, pkgs, lib, ... }:

let
  inherit (pkgs) callPackage;
  llib = callPackage ../../lib {inherit pkgs;};
  cont = callPackage ../../containers {
    emounts = {
      "/mnt/ys1/c".isReadOnly = false;
    };
    extraSrv = (llib.startupScriptC {name="mount_userdirs"; script=''
mountpoint -q /home/prsw/sh/vg && exit 1

BASE=/mnt/ys1/c
mountpoint -q "$BASE" || exit 1

for pa in "/home/prsw" "/home/prsw_net"; do
  for pb in "sh"; do
    for pc in "vg" ".wine/drive_c"; do
      P="$pa/$pb/$pc"
      if [ ! -e "$P" ]; then
        continue
      fi
      echo "== $P"
      mount --bind "$BASE$P" "$P"
    done
  done
done'';});
  };
  ssh_pub = (import ../../base/ssh_pub.nix).yalda;
  lpkgs = (import ../../pkgs {});
  ucode = (pkgs.callPackage ../../base/default_ucode.nix {});
in rec {
  # Pseudo-static stuff
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/term/desktop.nix
    ../../base/term/gaming_box.nix
    ../../base/term/game_pads.nix
    ../../base/site_wi.nix
    ../../fix
  ];

  #boot.kernelPackages = pkgs.linuxPackages_4_11;
  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix {inherit lib;});});
  boot.initrd.prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];

  containers = (cont.termC ssh_pub);
    
  ##### Host id stuff
  networking = {
    hostName = "yalda";
    hostId = "84d6fc01";
    #iproute2 = vars.iproute2;
    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [{
          address = "10.17.1.65";
          prefixLength = 24;
        }];
        ipv4.routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.17.1.1";
        }];
        ipv6.addresses = [
          { address = "2001:470:7af3:1:1:0:2:1"; prefixLength = 80;}
          { address = "fd9d:1852:3555:0200::41"; prefixLength = 56;}
        ];
        ipv6.routes = [
          { address = "fd9d:1852:3555::"; prefixLength = 48; via = "fd9d:1852:3555:200::1";}
          #{ address = "::"; prefixLength = 0; via = "2001:470:7af3:1:1::1";}
        ];
      };
    };
  };

  services.prometheus.exporters.smartctl = {
    devices = ["/dev/nvme0n1" "/dev/nvme1n1"];
    enable = true;
    maxInterval = "5m";
  };
  
  systemd = {
    services = {
      SH_mount_ys = {
        partOf = ["multi-user.target"];
        wantedBy = ["SH_containers_sh.service"];
        description = "SH_mount_ys";
        path = with pkgs; [coreutils eject lvm2 kmod cryptsetup utillinux];
        script = ''
mountpoint -q /mnt/ys1 && exit 0
# Set up /mnt/ys1
dmsetup mknodes
modprobe bcache

test -e /dev/mapper/ys1 || cryptsetup luksOpen --key-file=yalda_ys1 /dev/bcache/by-uuid/b3f9eb6c-511f-42bf-8542-50fb201fd8c9 ys1
#for disk in /dev/mapper/ys1 /dev/mapper/root_base0p2; {
  # Already registered disks will throw errors; ignore those
#  echo $disk > /sys/fs/bcache/register || true
#}
sleep 2 # wait for kernel to link disk label
mount /mnt/ys1
'';
      };
    };
    enableEmergencyMode = false;
  };

  services.udev = {
    extraRules = ''
      # Name network devices statically based on MAC address
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="04:d4:c4:57:f9:da", KERNEL=="eth*", NAME="eth_lan"
      # 2023-10-28 B760M DS3H AX
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="74:56:3c:46:b8:19", KERNEL=="eth*", NAME="eth_lan"
      # AMDGPU i2c DDC device
      SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="AMDGPU DM aux hw bus 2", MODE="0660", GROUP="video"
    '';
  };

  fileSystems = let
    baseOpts = ["noatime" "nodiratime"];
    btrfsOpts = baseOpts ++ ["space_cache=v2" "autodefrag" "ssd" "discard=async"];
  in {
    "/" = { label = "yalda_root"; options=btrfsOpts; };
    "/mnt/ys1" = { device = "/dev/mapper/ys1"; options=btrfsOpts ++ ["noauto"]; };
  };
  
  services.openssh.moduliFile = ./sshd_moduli;
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
}
