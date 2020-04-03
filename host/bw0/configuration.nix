# bw1 is a router box
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  lpkgs = (import ../../pkgs {});
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["127.0.0.1" "::1"];
  };
  ucode = (pkgs.callPackage ../../base/default_ucode.nix {});
  #nft_new = (pkgs.callPackage ../../pkgs/pkgs/nftables-0.9.2/default.nix {});
in {
  imports = [
    ./hardware-configuration.nix
    ./monitoring.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wl.nix
  ];

  ### Boot config
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix { structuredExtraConfig = (import ./kernel_conf.nix);});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    kernelParams = [
      # Reboot on kernel panic
      "panic=1" "boot.panic_on_fail"
      # Support serial console!
      "console=tty0" "console=ttyS0,115200"
    ];
    # loader.initScript.enable = true;
    initrd = {
      prepend = lib.mkOrder 1 [ "${ucode}/intel-ucode.img" ];
      luks.devices = [{
        name = "root";
        device = "/dev/disk/by-partlabel/bw0_r0_c";
        preLVM = true;
        fallbackToPassword = true;
        allowDiscards = true;
        keyFile = "/dev/disk/by-partlabel/bw0_key0";
        keyFileSize = 64;
      }];
      preFailCommands = ''${pkgs.bash}/bin/bash'';
      supportedFilesystems = ["btrfs"];
    };

    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/disk/by-id/usb-KINGSTON_SUV500MS240G_5002627783171569-0:0";
      fsIdentifier = "uuid";
      memtest86.enable = true;
      splashImage = null;
      extraConfig = "serial; terminal_output.serial";
    };

    # Enable packet routing.
    kernel.sysctl = {
      "net.ipv4.ip_forward" = mkForce true;
      "net.ipv4.conf.all.forwarding" = mkForce true;
      "net.ipv4.conf.default.forwarding" = mkForce true;
      "net.ipv6.conf.all.forwarding" = mkForce true;
    };
  };

  ### Networking
  networking = {
    hostName = "bw0.ulwired-ctl.s.";
    hostId = "84d5fcc8";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = false;

    interfaces = {
      #"eth_lan" = {
      #  ipv4.addresses = [{ address = "10.19.4.1"; prefixLength = 24;}];
      #  ipv6.addresses = [{ address = "fd9d:1852:3555:1200::1"; prefixLength = 80;}];
      #};
      "eth_o4" = {
        ipv6.addresses = [
          { address = "fd9d:1852:3555:200:ff00::1"; prefixLength = 64;}
        ];
      };
      "eth_l_wired" = {
        ipv4.addresses = [{ address = "10.17.1.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::1"; prefixLength=64;}];
      };
      "eth_l_wifi".ipv4.addresses = [{ address = "10.17.2.1"; prefixLength = 24; }];
      "eth_wan0".useDHCP = true;
      "eth_wan1".useDHCP = true;
    };
    # defaultGateway = "10.19.4.2";

    dhcpcd = {
        enable = true;
        extraConfig = ''
          nodelay
          hostname_short
          nogateway
          noipv4ll
          timeout 8
          nohook lookup, resolv.conf
        '';

        runHook = with pkgs; ''
          PATH=$PATH:${iproute}/bin
          # /usr/bin/env
          if [[ "$interface" = "eth_wan0" ]]; then
            TABLE="up_0";
          elif [[ "$interface" = "eth_wan1" ]]; then
            TABLE="up_1";
          else
            exit 0;
          fi
          # BOUND, RECONFIGURE,  NOCARRIER, EXPIRE, NAK
          set -x
          if [ "$reason" = BOUND -o "$reason" = RECONFIGURE ]; then
            ip rule add from "''${new_ip_address}"/32 priority 32767 table "''${TABLE}"
            for router in ''${new_routers}; do ip route add table "''${TABLE}" dev "''${interface}" via "''${router}" default; done;
          elif [ "$reason" = "EXPIRY" -o "$reason" = NOCARRIER -o "$reason" = NAK ]; then
            ip rule del priority 32767 table "''${TABLE}"
            ip route flush table "''${TABLE}";
          fi
          exit 0
        '';
    };

    iproute2 = {
      enable = true;
      rttablesExtraConfig = ''
      # local
      18 up_sticky
      19 up_0
      20 up_1
'';
    };

    localCommands = ''
      set +e
      # Link-probe addresses
      ip addr replace dev lo noprefixroute scope link 10.250.0.10
      ip addr replace dev lo noprefixroute scope link 10.250.0.11
      ip rule add priority 1024 from 10.250.0.10 table up_0
      ip rule add priority 1024 from 10.250.0.11 table up_1
      ip rule add priority 1025 from 10.250.0.0/24 blackhole
      ip rule add priority 40000 uidrange 2080-2080 table up_0
      ip rule add priority 40000 uidrange 2081-2081 table up_1
      ip rule add priority 40001 uidrange 2080-2081 blackhole
      # default routes
      ip rule add priority 65536 table up_1
      ip rule add priority 65537 table up_0
    '';

    nftables = {
      enable = true;
      rulesetFile = ./nft.conf;
    };
    # Push this way out of the way.
    #resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
    extraResolvconfConf = "resolv_conf=/etc/__resolvconf.out";
  };
  environment.etc."resolv.conf" = dns.resolvConf;

  services.dhcpd4 = {
    enable = true;
    configFile = ./dhcpd4.conf;
    interfaces = ["eth_l_wired" "eth_l_wifi"];
  };

  systemd = {
    enableEmergencyMode = false;
    # Put a getty on serial console.
    services."serial-getty@ttyS0".enable = true;
  };
  
  # Name network devices statically based on MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0c", KERNEL=="eth*", NAME="eth_wan0"    # "wan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0d", KERNEL=="eth*", NAME="eth_wan1"    # "lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0e", KERNEL=="eth*", NAME="eth_l_wired" # "o1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0f", KERNEL=="eth*", NAME="eth_l_wifi"  # "o2"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:10", KERNEL=="eth*", NAME="eth_o3"      # "o3"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:11", KERNEL=="eth*", NAME="eth_o4"      # "o4"
  '';

  # intel_pstate cpufreq driver, on a HWP CPU.
  # https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html#active-mode-with-hwp
  # this is likely to behave similar to 'ondemand' on other governors.
  powerManagement.cpuFreqGovernor = "powersave";

  ### System profile packages
  environment.systemPackages = with pkgs; with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    base
    cliStd
    nixBld

    openvpn
    iptables
    #nft_new

    # direct packages
    prometheus_2
    influxdb
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
    "/boot" = { device = "/dev/disk/by-partlabel/bw0_b0"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services.openssh = {
    enable = true;
    moduliFile = ./sshd_moduli;
  };
  services.bind = {
    enable = true;
    cacheNetworks = ["10.0.0.0/8" "127.0.0.0/8" "fd9d:1852:3555::/48" "192.168.0.0/16"];
    forwarders = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
    zones = [{
      name = "y";
      master = true;
      file = ./zones/y;
    } {
      master = true;
      file = ./zones/17.10.in-addr.arpa;
      name = "17.10.in-addr.arpa";
    }];
  };

  services.openntpd = {
    enable = true;
    extraConfig = ''
    listen on 127.0.0.1
    listen on ::1
    listen on 10.17.1.1
    listen on 10.17.2.1
    listen on 10.19.4.1
    constraint from "https://www.google.com/"
'';
  };
  services.uptimed.enable = true;
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ monitoring);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";
}
