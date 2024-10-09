# uiharu is a host box
{ config, pkgs, lib, l, ... }: {
  imports = (with l.conf; [
    default
    site
    (l.call ../../base/std_efi_boot.nix {structuredExtraConfig=(l.call ../bw0/kernel_conf.nix {});})
    ../../base/nox.nix
    ../../fix
  ]) ++ (with l.srv; [
    prom_exp_node
    wireguard
  ]);
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
    useNetworkd = true;
    nftables = {
      enable = true;
      ruleset = (l.call ./nft.nix {inPortStr="22";});
    };
  };
  systemd.network = l.netX "eth0";
  
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
