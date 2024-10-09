# Jibril is a desktop deployment with a focus on games.
{ config, pkgs, lib, l, ... }:

let
  inherit (pkgs) callPackage;
  inherit (lib) mkForce;
  cont = l.call ../../containers {};
  ssh_pub = (import ../../base/ssh_pub.nix).jibril;
  dns = import ../../base/dns.nix {
    nameservers = ["127.0.0.1" "::1"];
  };
in rec {
  imports = with l.conf; [
    default
    site
    ./hardware-configuration.nix
    (l.call ../../base/term/desktop.nix)
    (l.call ../../base/std_efi_boot.nix {structuredExtraConfig=(l.call ./kernel_conf.nix {});})
    (l.call ../../base/term/gaming_box.nix)
    ../../base/term/game_pads.nix
  ] ++ [l.srv.wireguard];
  
  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  nix.settings.max-jobs = 3;
  nix.settings.cores = 8;
  boot.initrd.luks.devices."root" = {
    device = "/dev/mapper/jibril_vg0-root";
    preLVM = mkForce false;
  };
  
  containers = (cont.termC ssh_pub);
  
  ### Networking
  networking = l.netHostInfo // {
    hostName = "jibril";
    useNetworkd = true;
  };
  systemd.network = l.netX "eth_lan";
  
  services.udev.extraRules = (builtins.readFile ./udev.rules);
  # powerManagement.cpuFreqGovernor = "powersave";

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["noatime" "nodiratime" "space_cache" "autodefrag"];
    };
    "/boot" = { device = "/dev/disk/by-partlabel/jibril_EFI_sys"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services.openssh.moduliFile = ./sshd_moduli;

  ### User / Group config
  # Define paired user/group accounts.
  users = l.lib.mkUserGroups (with l.vars.userSpecs {}; default ++ [sophia ilzo]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
}
