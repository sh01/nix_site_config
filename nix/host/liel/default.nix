# liel is a host box
{ config, pkgs, lib, l, ... }:
let
  inherit (lib) mkForce;
  ### Services
  gitit = name: ugid: port: (l.call ../../services/gitit.nix {inherit name ugid port;});
  planarallyS = name: ugid: port:  (l.call ../../services/planarally.nix {inherit name ugid port;});
  apache2 = l.call ../../services/apache2.nix {};
  vpn_c = (l.call ../../base/openvpn/client.nix {});
  c_vpn = (l.call ../../containers {}).c_vpn;
in {
  imports = (with l.conf; [
    default
    site
    ./hardware-configuration.nix
    ../../base/nox.nix
    ../../fix
    ../../base/ntp_client_default.nix
    (gitit "polis" 2019 8005)
    (gitit "rpg_c0" 2020 8006)

    (planarallyS "c0" 2021 8020)
    (planarallyS "ilzo" 2022 8021)
    (l.call ../../base/std_efi_boot.nix {structuredExtraConfig = (l.call ../bw0/kernel_conf.nix {});})
  ]) ++ (with l.srv; [
    prom_exp_node
    wireguard
  ]);

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
  networking = l.netHostInfo // {
    firewall.enable = false;
    useNetworkd = true;

    interfaces = {
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
  systemd.network = l.netX "eth0";

  environment.etc."resolv.conf" = l.dns.resolvConf;

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
  environment.systemPackages = with pkgs; with (l.call ../../pkgs/pkgs/meta {}); with (l.call ../../pkgs {}); [
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
  users = l.lib.mkUserGroups (with l.vars.userSpecs {}; default ++ [sophia ilzo ratheka openvpn stash]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";
}
