# Yalda is a desktop deployment with a focus on games.
{ config, pkgs, lib, l, ... }:

let
  inherit (pkgs) callPackage;
  cont = l.call ../../containers {
    emounts = {
      "/mnt/ys1/c".isReadOnly = false;
    };
    extraSrv = (l.lib.startupScriptC {name="mount_userdirs"; script=''
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
  ucode = callPackage ../../base/default_ucode.nix {};
in rec {
  imports = (with l.conf; [
    default
    site
    ./hardware-configuration.nix
    ../../base/term/boot.nix
    (l.call ../../base/term/desktop.nix)
    (l.call ../../base/term/gaming_box.nix)
    ../../base/term/game_pads.nix
    ../../fix
  ]) ++ [l.srv.wireguard];

  # hardware: RAM constraints
  nix.settings.cores = 3;
  nix.settings.max-jobs = 2;
  
  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackagesFor (l.call ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix {inherit lib;});});
  boot.initrd.prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];
  
  containers = (cont.termC ssh_pub);
    
  ##### Host id stuff
  networking = l.netHostInfo // {
    firewall.enable = false;
    hostName = "yalda";
    useNetworkd = true;
  };
  
  systemd = {
    services = {
      SH_mount_ys = rec {
        partOf = ["multi-user.target"];
        wantedBy = ["SH_containers_sh.service" "mnt-ys1.mount"];
        before = wantedBy;
        description = "SH_mount_ys";
        serviceConfig = {
          Restart = "on-failure";
          RemainAfterExit = "yes";
        };
        
        path = with pkgs; [coreutils eject lvm2 kmod cryptsetup utillinux];
        script = ''
mountpoint -q /mnt/ys1 && exit 0
# Set up /mnt/ys1
dmsetup mknodes
modprobe bcache

sleep 1
# aka /dev/disk/by-uuid/79c5f4e4-95a0-4bde-b623-c6a5a0c64b17
bdev="$(basename $(readlink /sys/fs/bcache/bf9dc10c-1c84-4a16-928e-d1019a4b30b9/bdev0/dev))"
test -e /dev/mapper/ys1 || cryptsetup luksOpen --key-file=/var/crypt/ys1 "/dev/$bdev" ys1
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
    network = l.netX "eth_lan";
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
