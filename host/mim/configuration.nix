# mim (Maintenance of Integrity through Monitoring) is a small checksum verifier.
{ config, pkgs, lib, ...}:
let
  lpkgs = (import ../../pkgs {});
in {
  networking = {
    hostName = "mim";
    useDHCP = false;
  };
  
  system.build.mim_image = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit config pkgs lib;
    name = "mim-disk-image";
    diskSize = 800;
    format = "raw";
  };

  environment.noXlibs = true;
  services = {
    openssh.enable = false;
    nixosManual.enable = false;
  };
  sound.enable = false;
  fonts.fontconfig.enable = false;
  hardware.opengl.driSupport = false;
  programs = {
    info.enable = false;
    man.enable = false;
    ssh.startAgent = false;
  };
  security.sudo.enable = false;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    #autoResize = true;
  };
      
  boot = {
    enableContainers = false;
    loader.grub = {
      device = "/dev/sda";
      copyKernels = true;
    };
    initrd = {
      extraUtilsCommands = ''
copy_bin_and_libs "${lpkgs.SH_blk_chk}/bin/blk_chk"
copy_bin_and_libs "${lpkgs.python3}/bin/python3*"
'';
      postDeviceCommands = ''
# Hacky dependency inclusion
# ${lpkgs.python3}
echo "Executing blk_chk... 0"
#mknod -m 600 /dev/urandom c 1 9
#mknod -m 666 /dev/null c 1 3
#mknod -m 600 /dev/console c 5 1
#${pkgs.strace}/bin/strace -e file
${lpkgs.SH_blk_chk}/bin/blk_chk
      '';
    };
  };
}
