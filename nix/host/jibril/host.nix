# liel is a host box
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = (pkgs.callPackage ../../lib {});
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["127.0.0.1" "::1"];
  };
in {
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wi.nix
    ../../fix/19_9.nix
  ];

  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    #kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix);});
    #kernelPackages = pkgs.linuxPackages_5_15;
    kernelPackages = pkgs.linuxPackages_5_9;
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    kernelParams = [
      # Reboot on kernel panic
      # "panic=1" "boot.panic_on_fail"
    ];
    # loader.initScript.enable = true;
    initrd = {
      kernelModules = ["vmd" "btrfs" "nvme" "pcieport" "sata_nv" "sata_ahci"];
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
      #canTouchEfiVariables = true;
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
      efiInstallAsRemovable = true;
    };
  };

  ### Networking
  networking = {
    hostName = "jibril";
    hostId = "84d5fccb";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = false;
    useNetworkd = false;

    interfaces = {
      "eth0" = {
        ipv4.addresses = [{ address = "10.17.1.7"; prefixLength = 24; }];
        ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.16.1.1"; }];
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::7"; prefixLength=64;}];
      };
    };

    nftables = {
      enable = true;
      rulesetFile = ./nft.conf;
    };
    # Push this way out of the way.
    resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
  };
  environment.etc."resolv.conf" = dns.resolvConf;

  # services.udev.extraRules = (builtins.readFile ./udev.rules);
  # powerManagement.cpuFreqGovernor = "powersave";

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    moreutils
    nixBld

    openvpn
    iptables
    radvd
    nftables

    # direct packages
    prometheus
    openntpd
    uptimed
  ];

  sound.enable = false;
  security.polkit.enable = false;

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["noatime" "nodiratime" "space_cache" "autodefrag"];
    };
    "/boot" = { device = "/dev/disk/by-partlabel/liel_b0"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services.openssh.moduliFile = ./sshd_moduli;

  services.openntpd = {
    enable = true;
    servers = ["10.16.1.1"];
    extraConfig = ''
    constraint from "https://www.google.com/"
'';
  };
  services.uptimed.enable = true;
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";
}
