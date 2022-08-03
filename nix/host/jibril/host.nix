# liel is a host box
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  inherit (pkgs) callPackage;
  cont = callPackage ../../containers {};
  ssh_pub = (import ../../base/ssh_pub.nix).jibril;
  slib = (pkgs.callPackage ../../lib {});
  vars = import ../../base/vars.nix {inherit lib;};
  lpkgs = (import ../../pkgs {});
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["127.0.0.1" "::1"];
  };
in rec {
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/term/desktop.nix
    ../../base/term/gaming_box.nix
    ../../base/site_wi.nix
    ../../fix/19_9.nix
  ];
  
  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix {inherit lib;});});
    #kernelPackages = pkgs.linuxPackages_5_15;
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    kernelParams = [
      # Reboot on kernel panic
      # "panic=1" "boot.panic_on_fail"
    ];
    # loader.initScript.enable = true;
    initrd = {
      kernelModules = ["vmd" "nvme" "btrfs"];
      luks.devices = {
        "root" = {
          device = "/dev/jibril_vg0/root";
          preLVM = false;
          fallbackToPassword = true;
          allowDiscards = true;
          #keyFile = "...";
          keyFileSize = 64;
        };
      };
      supportedFilesystems = ["btrfs"];
    };

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    loader.grub = {
      enable = true;
      copyKernels = true;
      version = 2;
      device = "nodev";
      # fsIdentifier = "uuid";
      splashImage = null;

      efiSupport = true;
      #efiInstallAsRemovable = true;
    };
  };

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
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [sophia]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "21.11";
}
