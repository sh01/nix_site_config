# liel is a host box
{ config, pkgs, lib, ... }:
let
  inherit (lib) mkForce;
  inherit (pkgs) callPackage;
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = callPackage ../../lib {};
  vars = callPackage ../../base/vars.nix {};
  dns = import ../../base/dns.nix {
    nameservers4 = ["10.17.1.1" "::1"];
  };
  gitit = name: ugid: port: (import ../../services/gitit.nix {inherit pkgs name ugid port;});
  planarallyS = name: ugid: port:  (import ../../services/planarally.nix {inherit pkgs name ugid port;});
  apache2 = callPackage ../../services/apache2.nix {};
  vpn_c = (import ../../base/openvpn/client.nix);
  c_vpn = (callPackage ../../containers {}).c_vpn;
in {
  imports = [
    ./hardware-configuration.nix
    ../../base
    ../../base/nox.nix
    ../../base/site_wi.nix
    ../../fix
    ../../fix/19_9.nix
    ../../base/ntp_client_default.nix
    ../../services/prom_exp_node.nix
    (gitit "polis" 2019 8005)
    (gitit "rpg_c0" 2020 8006)

    (planarallyS "c0" 2021 8020)
    (planarallyS "ilzo" 2022 8021)
    (import ../../base/std_efi_boot.nix {inherit pkgs; structuredExtraConfig = (import ../bw0/kernel_conf.nix {inherit lib;});})
  ];

  ### Boot config
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    kernelParams = ["panic=1" "boot.panic_on_fail" "usb-storage.quirks=174c:55aa:u"];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = mkForce true;
      "net.ipv4.conf.all.forwarding" = mkForce true;
    };
    initrd.luks.devices."root" = {
      device = "/dev/disk/by-partlabel/liel_r0_c";
      keyFile = "/dev/disk/by-partlabel/liel_key0";
      allowDiscards = true;
      bypassWorkqueues = true;
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
      "tun_vpn_o" = {
        virtual = true;
        virtualOwner = "openvpn";
        virtualType = "tun";
      };
    } // c_vpn.ifaces;

    nftables = {
      enable = true;
      rulesetFile = ./nft.conf;
    };

    bridges = c_vpn.br;
    # Push this way out of the way.
    resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
  };
  environment.etc."resolv.conf" = dns.resolvConf;

  systemd = {
    enableEmergencyMode = false;
    services = {
      SH_mount_liel_ext = {
        partOf = ["multi-user.target"];
        wantedBy = ["container@vpn-in.service"];
        before = ["container@vpn-in.service"];
        startLimitIntervalSec = 2;
        serviceConfig = {
          Restart = "on-failure";
        };
        path = with pkgs; [coreutils eject lvm2 kmod cryptsetup utillinux];
        script = ''
PART=/dev/disk/by-partlabel/liel_s0_vb
LVOL=s0_v

echo "Checking dm-mapper dev..."
if [ ! -e "/dev/mapper/$LVOL" ]; then
    if [ ! -e "$PART" ]; then
      echo "Part not ready: $PART"
      exit 100
    fi
    cryptsetup luksOpen --key-file /var/auth/v/s0_vb "$PART" "$LVOL"
    sleep 2;
fi

echo "Checking cryptpart mount..."
MP=/mnt/s0
mountpoint "$MP" || mount /dev/mapper/s0_vg-s0 "$MP"

echo "Checking bind mount..."
MBP=/var/lib/containers/vpn-in/var/lib/transmission/d
mountpoint "$MBP" || mount --bind /mnt/s0/liel/media_gshare/d/ "$MBP"

echo "Done."
'';
      };
    };
  };
  services.udev.extraRules = (builtins.readFile ./udev.rules);

  # intel_pstate cpufreq driver, on a HWP CPU.
  # https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html#active-mode-with-hwp
  # this is likely to behave similar to 'ondemand' on other governors.
  # powerManagement.cpuFreqGovernor = "powersave";

  ### System profile packages
  environment.systemPackages = with pkgs; with (callPackage ../../pkgs/pkgs/meta {}); with (callPackage ../../pkgs {}); [
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
    planarally
  ];

  sound.enable = false;
  security.polkit.enable = false;
  services.udisks2.enable = false;
  nixpkgs.config.packageOverrides = pkgs: {
    gnupg22 = pkgs.gnupg22.override { pcsclite = null; };
  };

  fileSystems = {
    "/" = { device = "/dev/mapper/root"; options=["discard" "ssd" "noatime" "nodiratime" "space_cache=v2"];};
    "/boot" = { device = "/dev/disk/by-partlabel/EFI_sys"; options=["noauto" "noatime" "nodiratime"];};
  };

  ### Services
  services.openssh.moduliFile = ./sshd_moduli;

  services.uptimed.enable = true;
  services.charybdis = {
    enable = true;
    config = (builtins.readFile ./charybdis.conf);
  };
  services.httpd = {
    enable = true;
    configFile = with apache2; confFile modsDefault [
      (fVhost "liel.x.s" [
        fUserdirs fUserdirsCGIsh
        ''
DocumentRoot /var/www/
<Location "/lmc">
  Options Indexes
  <Limit GET POST OPTIONS>
    Require all granted
  </Limit>
</Location>
''])
      (fVhost "polis-wiki.s" [
        (fAuth {name="polis-wiki.s"; fn="/etc/www/polis_wiki/auth_digest";})
        (fForward "http://127.0.0.2:8005/")
      ])
      (fVhost "rpg-c0-wiki" [
        ''    ServerAlias rpg-c0-wiki.s rpg-c0-w.memespace.net''
        (fAuth {name="rpg-c0-w.memespace.net"; fn="/etc/www/rpg_c0_wiki/auth_digest";})
        (fForward "http://127.0.0.2:8006/")
      ])
      (fVhost "rpg-pa.x.s" [
        (fForward "http://127.0.0.2:8020/")
      ])
      (fVhost "i-pa.x.s" [
        (fForward "http://127.0.0.2:8021/")
      ])
    ];
  };

  services.openvpn.servers = {
    # Outgoing to ika
    vpn-ocean = {
      config = vpn_c.config (vpn_c.ocean // {
        cert = ../../data/vpn-o/c_liel.crt;
      });
    };
  };

  containers = c_vpn.cont {
    services.transmission = {
      enable = true;
      downloadDirPermissions = "755";
      settings = {
        download-dir = "/var/lib/transmission/d";
        incomplete-dir-enabled = false;
        incomplete-dir = "/var/lib/transmission/temp";
        peer-port = 54921;
        port-forwarding-enabled = false;
        rpc-authentication-required = true;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "127.*.*.*,10.16.*.*,10.17.*.*,10.231.*.*";
        rpc-whitelist-enabled = true;
      };
      performanceNetParameters = true;
    };
    systemd.services.transmission.serviceConfig = {
      # Default pre-startup script does not respect any local changes, but auth credentials do not belong into nix store. Disable the script here.
      ExecStartPre = mkForce null;
      # Nix 24.05: Work around https://github.com/NixOS/nixpkgs/issues/258793
      BindReadOnlyPaths = lib.mkForce [builtins.storeDir "/etc"];
      RootDirectoryStartOnly = lib.mkForce false;
      RootDirectory = lib.mkForce "";
    };
  };
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [sophia ilzo ratheka openvpn stash]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";
}
