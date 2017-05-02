# Likol is a small server deployment.
{ config, pkgs, lib, ... }:

let
  lpkgs = (import ../../pkgs {});
  ssh_pub = import ../../base/ssh_pub.nix;
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
  dns = (import ../../base/dns.nix) {
    searchPath = [];
    nameservers4 = ["8.8.8.8"];
  };
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
      useDHCP = true;
      };
    };
    dhcpcd = {
      persistent = true;
      allowInterfaces = ["eth_lan"];
    };
    firewall.enable = false;
    useDHCP = true;

    #defaultGateway = "10.16.0.1";
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
      getmail_gmx = {
        wantedBy = ["multi-user.target"];
        description = "getmail: GMX";
        path = with pkgs; [sudo dspam getmail maildrop];
        serviceConfig = {
          Restart = "always";
          RestartSec = 600;
          RuntimeMaxSec = 1800;
	};
        script = ''
cd /var/local/mail/sh;
exec sudo -u mail-sh getmail -r /var/local/etc/getmail/gmx 2>&1 | grep -v '^Copyright (C)'
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

    # non-nix-service parts of mail setup.
    maildrop
    getmail
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

  services.dovecot2 = {
    enable = true;
    configFile = pkgs.copyPathToStore ./dovecot.conf;
  };

  # dspam doesn't self-setup its postgresql tables; for a fresh install, look
  # for and run (via psql) the two /nix/store/*-dspam-*/share/dspam/sql/pgsql*.sql
  # setup scripts.
  # We do not expect this to come up.
  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    package = pkgs.postgresql96;
    authentication = ''
local all dspam peer
local all root peer
'';
    extraConfig = ''
listen_addresses = '''
bgwriter_flush_after = 0
effective_io_concurrency = 4
backend_flush_after = 0
synchronous_commit = off
commit_delay = 80000
#fsync = off
wal_compression = on
checkpoint_flush_after = 0
'';
  };
  
  services.dspam = {
    enable = true;
    storageDriver = "pgsql";
    extraConfig = ''
PgSQLServer /tmp/
PgSQLDb     dspam

UserLog off
SystemLog off
OnFail unlearn
TrainingMode teft
TestConditionalTraining on
Feature noise
Feature whitelist
Algorithm graham burton
PValue graham
ImprobabilityDrive on

ServerPass.Local0 "nonsecret"
ClientIdent "nonsecret@Local0"

Preference "spamAction=tag"
Preference "signatureLocation=headers"
Preference "spamSubject="
IgnoreHeader X-Virus-Scanner-Result
IgnoreHeader X-Spam-Checker-Version
IgnoreHeader X-Spam-Level
IgnoreHeader X-Spam-Status
IgnoreHeader X-Spam-CMAETAG
IgnoreHeader X-Spam-CMAECATEGORY: 0
IgnoreHeader X-Spam-CMAESUBCATEGORY: 0
IgnoreHeader X-Spam-CMAESCORE

IgnoreHeader X-DSPAM-Result
IgnoreHeader X-DSPAM-Processed
IgnoreHeader X-DSPAM-Confidence
IgnoreHeader X-DSPAM-Improbability
IgnoreHeader X-DSPAM-Probability
IgnoreHeader X-DSPAM-Signature
IgnoreHeader X-DSPAM-Factors

IgnoreHeader X-GMX-Antispam
IgnoreHeader X-GMX-Antivirus
IgnoreHeader X-UI-Filterresults

IgnoreHeader X-Virus-Scanned
IgnoreHeader X-Antivirus
IgnoreHeader X-Original-To
IgnoreHeader Received
IgnoreHeader Return-path
IgnoreHeader X-Mailman-Version
IgnoreHeader X-BeenThere
IgnoreHeader Delivered-To
IgnoreHeader Errors-To
IgnoreHeader List-Subscribe
IgnoreHeader List-Unsubscribe
IgnoreHeader List-Post
IgnoreHeader List-Archive
IgnoreHeader List-Help
IgnoreHeader List-Post
IgnoreHeader List-Id
IgnoreHeader Sender
IgnoreHeader Precedence
IgnoreHeader X-Sieve
IgnoreHeader Mime-version
IgnoreHeader Reply-To
IgnoreHeader Content-Type

LocalMX 134.119.228.54

ProcessorWordFrequency  occurrence
ProcessorBias on
'';
  };
  
  ### User / Group config
  # Define paired user/group accounts.
  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [cc sh_yalda es_github openvpn dovecot-auth mail-sh]);

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
