# liel is a host box
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = (pkgs.callPackage ../../lib {});
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["10.17.1.1" "::1"];
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
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ../bw0/kernel_conf.nix);});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    kernelParams = [
      # Reboot on kernel panic
      "panic=1" "boot.panic_on_fail"
    ];
    # loader.initScript.enable = true;
    initrd = {
      luks.devices = {
        "root" = {
          device = "/dev/disk/by-partlabel/liel_r0_c";
          preLVM = true;
          fallbackToPassword = true;
          allowDiscards = true;
          keyFile = "/dev/disk/by-partlabel/liel_key0";
          keyFileSize = 64;
        };
      };
      preFailCommands = ''${pkgs.bash}/bin/bash'';
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
      #device = "/dev/disk/by-id/ata-Micron_M600_MTFDDAT128MBF_14450F3723E9";
      device = "nodev";
      # fsIdentifier = "uuid";
      # memtest86.enable = true;
      splashImage = null;

      efiSupport = true;
      #efiInstallAsRemovable = true;
    };
  };

  ### Networking
  networking = {
    hostName = "liel";
    hostId = "84d5fcca";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = false;
    useNetworkd = false;

    interfaces = {
      #"eth_lan" = {
      #  ipv4.addresses = [{ address = "10.19.4.1"; prefixLength = 24;}];
      #  ipv6.addresses = [{ address = "fd9d:1852:3555:1200::1"; prefixLength = 80;}];
      #};
      "eth0" = {
        ipv4.addresses = [{ address = "10.17.1.6"; prefixLength = 24; }];
        ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::6"; prefixLength=64;}];
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

  systemd = {
    enableEmergencyMode = false;
  };
  services.udev.extraRules = (builtins.readFile ./udev.rules);

  # intel_pstate cpufreq driver, on a HWP CPU.
  # https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html#active-mode-with-hwp
  # this is likely to behave similar to 'ondemand' on other governors.
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
  services.udisks2.enable = false;
  nixpkgs.config.packageOverrides = pkgs: {
    gnupg22 = pkgs.gnupg22.override { pcsclite = null; };
    logrotate = pkgs.logrotate.override { mailutils = null; };
  };

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

  services.chrony = {
    enable = true;
    servers = ["10.17.1.1"];
    #extraConfig = ''
    #constraint from "https://www.google.com/"
#'';
  };
  services.uptimed.enable = true;
  services.charybdis = {
    enable = true;
    config = (builtins.readFile ./charybdis.conf);
  };
  services.httpd = {
    enable = true;
    adminAddr = ".";
    extraConfig = ''
LogFormat "%{%Y-%m-%d_%H:%M:%S}t.%{usec_frac}t %h %l %u \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" clog
'';
    logFormat = "clog";
    virtualHosts = {
      "liel.x.s" = {
        #addSSL = true;
        enableUserDir = true;
        logFormat = "clog";
        extraConfig = ''
<Directory "/home/*/public_html">
		Options +ExecCGI
</Directory>
AddHandler cgi-script .cgi .py
'';
      };
    };
  };
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";
}
