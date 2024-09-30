# uiharu is a host box
{ config, pkgs, lib, l, ... }: {
  imports = with l.conf; [
    default
    site
    l.srv.prom_exp_node
    (l.call ../../base/std_efi_boot.nix {structuredExtraConfig=(l.call ../bw0/kernel_conf.nix {});})
    ../../base/nox.nix
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

  networking = l.netHostInfo // {
    firewall.enable = false;
    interfaces = {
      "eth0" = l.ifaceDmz;
    };
  };
  
  fileSystems = {
    "/" = { device = "/dev/mapper/root"; options=["discard" "ssd" "noatime" "nodiratime" "space_cache=v2"];};
    "/boot" = { device = "/dev/disk/by-partlabel/EFI_sys"; options=["noauto" "noatime" "nodiratime"];};
  };

  environment.systemPackages = with pkgs; with (l.call ../../pkgs/pkgs/meta {}); with (l.call ../../pkgs {}); [
    base
  ];
  environment.etc."resolv.conf" = l.dns.resolvConf;
  
  ### Services
  services = {
    openssh.moduliFile = ./sshd_moduli;
  };

  ### User / Group config
  # Define paired user/group accounts.
  users = l.lib.mkUserGroups (with l.vars.userSpecs {}; default);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "24.05";
}
