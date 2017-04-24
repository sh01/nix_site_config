# Keiko is a storage system.
{ config, pkgs, lib, ... }:

let
  lpkgs = (import ../../pkgs {});
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {};
  vpn_c = (import ../../base/openvpn/client.nix);
in {
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_stellvia.nix
  ];


  ### Boot config
  boot = {
    kernelPackages = pkgs.linuxPackages_4_4;
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    # loader.initScript.enable = true;
    initrd.luks.devices = [ {
      name = "luksVg0";
      device = "/dev/sdb3";
      preLVM = true;
    }];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
      fsIdentifier = "label";
      memtest86.enable = true;
      splashImage = null;
    };
  };
  ##### Host id stuff
  networking = {
    hostName = "likol.sh.s";
    hostId = "84d5fcc8";
    usePredictableInterfaceNames = false;
    interfaces = {
      "eth_lan" = {
        ip4 = [{
          address = "10.16.0.3";
          prefixLength = 24;
        }];
        ip6 = [{
          address = "fd9d:1852:3555:200::3";
          prefixLength = 80;
        }];
      };
    };
    firewall.enable = false;
    useDHCP = false;
    dhcpcd.allowInterfaces = [];

    defaultGateway = "10.16.0.1";
    extraResolvconfConf = "resolv_conf=/etc/__resolvconf.out";
  } // dns.conf;

  systemd = {
    services = {
      SH_limit_cpufreq = {
        wantedBy = ["sysinit.target"];
        description = "SH_limit_cpufreq";
        path = with pkgs; [coreutils cpufrequtils];
        script = ''
for i in 0 1 2 3 4 5 6 7; do cpufreq-set -c $i --max 1.2G; done
'';
      };
    };
    enableEmergencyMode = false;
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:90:f5:d4:e4:dc", KERNEL=="eth*", NAME="eth_lan"
  '';

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    nixBld

    openvpn
    iptables
    nftables
  ];

  sound.enable = false;
  security.polkit.enable = false;

  environment.etc = {
    "resolv.conf" = dns.resolvConf;
  };

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/vg0/root";
      fsType = "btrfs";
      options = ["noatime" "nodiratime" "space_cache" "autodefrag"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/\\x2fboot";
      options = ["noatime" "nodiratime"];
    };
  };

  ### Networking

  ### Services
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;

  services.openvpn.servers = {
    # Outgoing to ika
    vpn-ocean = {
      config = vpn_c.config (vpn_c.ocean // {
        cert = ../../data/vpn-o/c_likol.crt;
        key = "/var/auth/vpn_ocean_likol.key";
      });
    };
    # vpn-base server
    vpn-base = {
      config = (pkgs.callPackage ./vpn-base.nix {lpkgs=lpkgs;});
    };
  };
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [cc sh_yalda es_github openvpn]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
