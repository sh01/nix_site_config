# bw0 is a router box
{ config, pkgs, lib, l, ... }:

let
  inherit (lib) mkForce;
  dns = (import ../../lib/dns.nix) {
    nameservers = ["127.0.0.1" "::1"];
    inherit (l.site.dns_params) searchPath;
  };
in {
  imports = (with l.conf; [
    default
    site
    ./hardware-configuration.nix
    ./monitoring.nix
    ../../base/nox.nix
    ../../fix
  ]) ++ (with l.srv; [
    wireguard
  ]);

  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../base/default_kernel.nix {structuredExtraConfig = (import ./kernel_conf.nix {inherit lib;});});
    #kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_latest.override { structuredExtraConfig = (import ./kernel_conf.nix);});
    blacklistedKernelModules = ["snd" "rfkill" "fjes" "8250_fintek" "eeepc_wmi" "autofs4" "psmouse"] ++ ["firewire_ohci" "firewire_core" "firewire_sbp2"];
    kernelParams = [
      # Reboot on kernel panic
      "panic=1" "boot.panic_on_fail"
      # Support serial console!
      "console=tty0" "console=ttyS0,115200"
    ];
    # loader.initScript.enable = true;
    initrd = {
      luks.devices = {
        "root" = {
          device = "/dev/disk/by-partlabel/bw2_r0_c";
          preLVM = true;
          fallbackToPassword = true;
          allowDiscards = true;
          keyFile = "/dev/disk/by-partlabel/bw2_key0";
          keyFileSize = 64;
        };
      };
      preFailCommands = ''${pkgs.bash}/bin/bash'';
      supportedFilesystems = ["btrfs"];
    };

    loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/ata-JAJMS600M1TB_AB202100000003000921";
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
    hostName = "bw0";
    hostId = "84d5fcc9";
    
    firewall.enable = false;
    useNetworkd = true;

    interfaces = {
      #"eth_lan" = {
      #  ipv4.addresses = [{ address = "10.19.4.1"; prefixLength = 24;}];
      #  ipv6.addresses = [{ address = "fd9d:1852:3555:1200::1"; prefixLength = 80;}];
      #};
      #"eth_o4" = {
      #  ipv6.addresses = [
      #    { address = "fd9d:1852:3555:1200:ff00::1"; prefixLength = 64;}
      #  ];
      #};
      "eth_l_wired" = {
        ipv4 = {
          addresses = [
            { address = "10.17.1.1"; prefixLength = 24; }
            { address = "10.17.8.255"; prefixLength = 24; }
          ];
          routes = [
            { address = "10.17.1.0"; prefixLength = 24; }
            { address = "10.17.8.0"; prefixLength = 24; }
          ];
        };
        ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::1"; prefixLength=64;}];
      };
      "eth_l_wifi".ipv4 = {
        addresses = [{ address = "10.17.2.1"; prefixLength = 24; }];
        routes = [{ address = "10.17.2.0"; prefixLength = 24; }];
      };
      "eth_l_wifi_g".ipv4 = {
        addresses = [{ address = "10.17.3.1"; prefixLength = 24; }];
        routes = [{ address = "10.17.3.0"; prefixLength = 24; }];
      };
      "eth_wan0" = {
        useDHCP = true;
        tempAddress = "disabled";
      };
      "eth_wan1" = {
        useDHCP = true;
        tempAddress = "disabled";
      };
      "tun6_0" = {
        virtual = true;
        virtualType = "tun";
      };
      "tun6_1" = {
        virtual = true;
        virtualType = "tun";
      };
    };

    # (Handled by networkd)
    dhcpcd.enable = false;
    
    iproute2 = {
      enable = true;
      rttablesExtraConfig = ''
      # local
      18 up_sticky
      19 up_0
      20 up_1
      21 l_up_0
      22 l_up_1
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
      for v in 4 6; do
        ip -$v rule add priority 40000 uidrange 2080-2080 table up_0
        ip -$v rule add priority 40000 uidrange 2081-2081 table up_1
        ip -$v rule add priority 40001 uidrange 2080-2081 blackhole
# default routes
        ip -$v rule add priority 65536 table up_1
      done
# No 6to4 support. Boo!
      ip -4 rule add priority 65537 table up_0
      ip -6 rule add priority 30000 table l_up_1
      ip -6 rule add priority 30000 table l_up_0

      # Rerun nft setup here; it needs nixos's virtual ifaces to be created, and
      # Nix runs its own nftables setup before that step.
      ${pkgs.nftables}/bin/nft -f ${./nft.conf}
      true
    '';

    nftables = {
      enable = true;
      rulesetFile = ./nft.conf;
    };
    # Push this way out of the way.
    resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
  };
  environment.etc."resolv.conf" = dns.resolvConf;

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = (import ./kea-dhcp4.nix);
    };
  };

  services.radvd = {
    enable = false;
    config = (builtins.readFile ./radvd.conf);
  };

  systemd = {
    enableEmergencyMode = false;
    # Put a getty on serial console.
    services."serial-getty@ttyS0".enable = true;
    network.wait-online.ignoredInterfaces = ["eth_wan1" "tun6_0" "tun6_1"];
  };
  
  # Name network devices statically based on MAC address
  # Ports, in order: "wan", "lan", "o1", "o2", "o3", "o4"
  services.udev.extraRules = ''
    # == bw0
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0c", KERNEL=="eth*", NAME="eth_wan0"
    # phy: wan
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0d", KERNEL=="eth*", NAME="eth_wan1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0e", KERNEL=="eth*", NAME="eth_l_wired"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0f", KERNEL=="eth*", NAME="eth_l_wifi"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:10", KERNEL=="eth*", NAME="eth_l_wifi_g"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:11", KERNEL=="eth*", NAME="eth_o4"

    # == bw2
    # physically: "lan"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e4", KERNEL=="eth*", NAME="eth_o_borked"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e5", KERNEL=="eth*", NAME="eth_wan1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e6", KERNEL=="eth*", NAME="eth_l_wired"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e7", KERNEL=="eth*", NAME="eth_l_wifi"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e8", KERNEL=="eth*", NAME="eth_l_wifi_g"
    # physically: "opt4"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:2c:c5:e9", KERNEL=="eth*", NAME="eth_wan0"
  '';

  # intel_pstate cpufreq driver, on a HWP CPU.
  # https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html#active-mode-with-hwp
  # this is likely to behave similar to 'ondemand' on other governors.
  powerManagement.cpuFreqGovernor = "powersave";

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
    influxdb
    openntpd
    uptimed
    #dhcp
  ];

  sound.enable = false;
  security.polkit.enable = false;
  security.sudo.wheelNeedsPassword = false;

  fileSystems = {
    "/" = {
      label = "root";
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["noatime" "nodiratime" "space_cache" "autodefrag" "discard=async"];
    };
    "/boot" = { device = "/dev/disk/by-partlabel/bw2_b0"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services.openssh.moduliFile = ./sshd_moduli;
  services.bind = {
    enable = true;
    cacheNetworks = ["10.0.0.0/8" "127.0.0.0/8" "fd9d:1852:3555::/48" "192.168.0.0/16"];
    extraOptions = "qname-minimization off;";  # Mitigate CVE-2020-8621
    forwarders = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
    zones = [{
      name = "s";
      master = true;
      file = ./zones/s;
    } {
      master = true;
      file = ./zones/17.10.in-addr.arpa;
      name = "17.10.in-addr.arpa";
    }];
  };

  services.openntpd = {
    enable = false;
  };
  services.ntp = {
    enable = true;
    restrictDefault = [];
    restrictSource = [];
    extraConfig = ''
    nic ignore all
    nic listen 127.0.0.0/8
    nic listen ::1/128
    nic listen 10.17.1.1
    nic listen 10.17.2.1
    nic listen 10.19.4.1
    nic listen fd9d:1852:3555:101::1
    #constraints from "www.google.com"
'';
  };
  services.timesyncd.enable = false;
  services.uptimed.enable = true;
  
  ### User / Group config
  # Define paired user/group accounts.
  users = l.lib.mkUserGroups (with l.vars.userSpecs {}; default ++ monitoring);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";
}
