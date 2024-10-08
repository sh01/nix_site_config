# Jibril is a desktop deployment with a focus on games.
{ config, pkgs, lib, l, ... }:

let
  inherit (pkgs) callPackage;
  cont = l.call ../../containers {};
  ssh_pub = (import ../../base/ssh_pub.nix).jibril;
  dns = import ../../base/dns.nix {
    nameservers4 = ["127.0.0.1" "::1"];
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
  ];
  
  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  nix.settings.max-jobs = 3;
  nix.settings.cores = 8;
  boot.initrd.luks.devices."root".device = "/dev/mapper/jibril_vg0-root";
  
  containers = (cont.termC ssh_pub);

  ### Networking
  networking = {
    hostName = "jibril";
    hostId = "84d5fccb";

    interfaces = {
      "eth_lan" = {
        ipv4.addresses = [{ address = "10.17.1.70"; prefixLength = 24; }];
        ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::7"; prefixLength=64;}];
      };
    };
  };
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
