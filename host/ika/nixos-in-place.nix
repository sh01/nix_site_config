{ config, pkgs, ... }:
let
  sys_scripts = (import ../../pkgs {}).SH_sys_scripts;
in {
  ## Everything below is generated from nixos-in-place; modify with caution!
  boot.kernelParams = ["boot.shell_on_fail"];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.storePath = "/nixos/nix/store";
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.postDeviceCommands = ''
    mkdir -p /mnt-root/old-root ;
    mount -t ext4 /dev/vda1 /mnt-root/old-root ;
  '';
  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "/old-root" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };
  # services.openssh.enable = true;
  # users.extraUsers.root.password = "nixos";
    ## Digital Ocean networking setup; manage interfaces manually
    # networking.useDHCP = false;

    systemd.services.setup-network = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-pre.target" "local-fs.target" ];
      path = [ pkgs.iproute pkgs.openresolv ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${sys_scripts}/bin/ifup.py /etc/network/interfaces";
      };
    };
}
