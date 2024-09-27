# uiharu is a host box
{ config, pkgs, lib, lwCall, llib, lvars, ... }:
let
  site = (lwCall ../../base/site_vars.nix {}).wi;
in {
  imports = [
    ../../base
    (import ../../base/std_efi_boot.nix {inherit pkgs; structuredExtraConfig=(import ../bw0/kernel_conf.nix {inherit lib;});})
    ../../base/nox.nix
    ../../base/site_wi.nix
    ../../fix
  ];
  #boot.loader.grub.device = "nodev";
  ### Hardware
  hardware.cpu.intel.updateMicrocode = true;
  nix.settings.max-jobs = 2;
  
  boot = {
    kernelParams = ["panic=1" "boot.panic_on_fail"];
  
    initrd.luks.devices."root" = {
      device = "/dev/disk/by-partlabel/uiharu_r0_c";
      keyFile = "/dev/disk/by-partlabel/uiharu_key0";
      allowDiscards = true;
      bypassWorkqueues = true;
    };
  };

  networking = (lvars.netHostInfo "uiharu") // {
    firewall.enable = false;
    interfaces = {
      "eth0" = (site.mkIface 6);
    };
  };
  
  fileSystems = {
    "/" = { device = "/dev/mapper/root"; options=["discard" "ssd" "noatime" "nodiratime" "space_cache=v2"];};
    "/boot" = { device = "/dev/disk/by-partlabel/EFI_sys"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services = {
    openssh.moduliFile = ./sshd_moduli;
  };

  ### User / Group config
  # Define paired user/group accounts.
  users = llib.mkUserGroups (with lvars.userSpecs {}; default);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "24.05";
}
