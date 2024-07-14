# bw2 is a router box
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkForce;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = (pkgs.callPackage ../../lib {});
  vars = pkgs.callPackage ../../base/vars.nix {};
  dns = (import ../../base/dns.nix) {
    nameservers4 = ["127.0.0.1" "::1"];
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./monitoring.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wi.nix
    ../../fix/19_9.nix
  ];

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
    hostName = "bw2";
    hostId = "84d5fcc9";
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
    # defaultGateway = "10.19.4.2";

    dhcpcd = {
      enable = true;
      allowInterfaces = ["eth_wan0" "eth_wan1"];
      extraConfig = ''
          nodelay
          hostname_short
          nogateway
          noipv4ll
          timeout 8
          nohook lookup, resolv.conf
          noipv6rs
          waitip 4

          interface eth_wan0
            persistent
          interface eth_wan1
            persistent
            #ipv6
            #dhcp6
            #ia_na
            #ipv6rs
      '';

      runHook = with pkgs; ''
          PATH=$PATH:${iproute}/bin:${coreutils}/bin
          #/usr/bin/env > "/tmp/t0/$$"
          if [[ "$interface" = "eth_wan0" ]]; then
            WIDX=0
            ip route add 192.168.1.254/32 dev "$interface"
          elif [[ "$interface" = "eth_wan1" ]]; then
            WIDX=1
          else
            exit 0
          fi

          TABLE="up_''${WIDX}"
          IF6="tun6_''${WIDX}"
          new_prefix="$(printf "2002:%02x%02x:%02x%02x" $(echo ''${new_ip_address} | tr "." " "))"

          # BOUND, RECONFIGURE,  NOCARRIER, EXPIRE, NAK
          set -x
          if [ "$reason" = BOUND -o "$reason" = RECONFIGURE -o "$reason" = REBOOT ]; then
            ip rule add from "''${new_ip_address}"/32 priority 32767 table "''${TABLE}"
            for router in ''${new_routers}; do ip route add table "''${TABLE}" dev "''${interface}" via "''${router}" default; done

            # set up 6to4 tunnel
            ip tunnel add "''${IF6}" mode sit ttl 64 remote any local "''${new_ip_address}" || true
            ip link set dev "''${IF6}" up || true
            ip -6 addr add ''${new_prefix}::1/48 dev "''${IF6}" || true
            ip -6 route add default via ::192.88.99.1 dev "''${IF6}" metric 1 table "''${TABLE}" || true
            ip -6 route add ''${new_prefix}:200::/64 dev eth_l_wired table "l_''${TABLE}"

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
  };
  
  # Name network devices statically based on MAC address
  # Ports, in order: "wan", "lan", "o1", "o2", "o3", "o4"
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0c", KERNEL=="eth*", NAME="eth_wan0"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0d", KERNEL=="eth*", NAME="eth_wan1"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0e", KERNEL=="eth*", NAME="eth_l_wired"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:0f", KERNEL=="eth*", NAME="eth_l_wifi"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:10", KERNEL=="eth*", NAME="eth_o3"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:e0:67:1a:5e:11", KERNEL=="eth*", NAME="eth_o4"

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
    dhcp
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
    #constraints from "www.google.com"
'';
  };
  services.timesyncd.enable = false;
  services.uptimed.enable = true;
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ monitoring);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";
}
