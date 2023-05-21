{ config, pkgs, lib, ... }:
with lib;
let
  slib = (pkgs.callPackage ../../lib {});
  influx_addr = "127.0.0.5:";
  # prometheus config things
  writePrettyJSON = name: x:
    pkgs.runCommand name { } ''
      echo '${builtins.toJSON x}' | ${pkgs.jq}/bin/jq . > $out
    '';
  promConfig = let
    cfg = config.services.prometheus;
  in {
    global = cfg.globalConfig;
    rule_files = cfg.ruleFiles ++ [
      (pkgs.writeText "prometheus.rules" (concatStringsSep "\n" cfg.rules))
    ];
    scrape_configs = cfg.scrapeConfigs;
  };
  promYml = writePrettyJSON "prometheus.yml" promConfig;
  blackbox_ip = "127.0.0.1";
  blackbox_tcp0 = blackbox_ip + ":9115";
  blackbox_tcp1 = blackbox_ip + ":9116";
  prom_bb = (import ./prometheus_bb.nix);
  icmp_probe = {name, addr}: {
        job_name = name;
        metrics_path = "/probe";
        params = { module = ["icmp_ping"]; } ;
        scrape_interval = "64s";
        static_configs = [{targets = ["8.8.8.8" "www.amazon.com" "l.root-servers.org"];}];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = addr; source_labels = [];}
        ];
  };
  http_probe = {name, addr}: {
        job_name = name;
        metrics_path = "/probe";
        params = { module = ["http_2xx"]; };
        scrape_interval = "256s";
        static_configs = [{targets = ["www.google.com" "www.amazon.com"];}];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = addr; source_labels = [];}
        ];
  };
  nft_configs = [{targets = ["localhost:9101"];}];
in rec {
  imports = [
    ../../pkgs/pkgs/nft_prom/service.nix
  ];
  # Prometheus
  systemd.services = {
    #prometheus.script = mkForce "exec ${pkgs.prometheus}/bin/prometheus --config.file=${promYml} --storage.tsdb.retention=128y";
    "prometheus-blackbox-exporter-0" = prom_bb {inherit pkgs; listen="127.0.0.1:9115"; user="mon_0";};
    "prometheus-blackbox-exporter-1" = prom_bb {inherit pkgs; listen="127.0.0.1:9116"; user="mon_1";};
  };

  services.prometheus = {
    enable = true;
    extraFlags = ["--storage.tsdb.retention=128y"];
    globalConfig = {
      scrape_interval = "32s";
      evaluation_interval = "32s";
      scrape_timeout = "32s";
    };
    scrapeConfigs = [
      (icmp_probe {name = "up0_icmp"; addr=blackbox_tcp0;})
      (icmp_probe {name = "up1_icmp"; addr=blackbox_tcp1;})

      (http_probe {name = "up0_http"; addr=blackbox_tcp0;})
      (http_probe {name = "up1_http"; addr=blackbox_tcp1;})

      {
        job_name = "node";
        scrape_interval = "256s";
        static_configs = [{targets = ["localhost:9100" "jibril.x.s.:9100" "yalda.sh.s.:9100" "liel.x.s.:9100"];}];
      } {
        job_name = "nft_prom";
        metrics_path = "/probe";
        params = { ct_name_fmt = ["^(?P<dir>[io])/(?P<iface>[^/]*)/(?P<ttype>[^/]*)$"]; };
        scrape_interval = "64s";
        static_configs = nft_configs;
      } {
        job_name = "nft_prom_ii";
        metrics_path = "/probe_ifaces";
        scrape_interval = "96s";
        static_configs = nft_configs;
      } {
        job_name = "envmon";
        metrics_path = "/probe";
        scrape_interval = "64s";
        static_configs = [
          {targets = [
"1.sens.s.:80"
"2.sens.s.:80"
"3.sens.s.:80"
"4.sens.s.:80"
"5.sens.s.:80"
          ];}
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        listenAddress = blackbox_ip;
        disabledCollectors = [
          "arp"
          "bcache"
          "bonding"
          "buddyinfo"
          "entropy"
          "filefd"
          "interrupts"
          "ipvs"
          "loadavg"
          "mdadm"
          "nfs"
          "nfsd"
          "textfile"
          "uname"
          "time"
          "xfs"
          "zfs"
        ];
        enabledCollectors = [
          "ntp"
          "timex"
        ];
        extraFlags = [
          "--collector.ntp.server-is-local"
          "--collector.netstat.fields=Ip(6|Ext)_(InOctets|OutOctets)"
          "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs|ramfs|tmpfs)$"
        ];
      };
    };
  };

  services.grafana = {
    enable = true;
    auth.anonymous = {
      enable = true;
      org_name = "main";
    };
    users.allowSignUp = false;
    addr = "0.0.0.0";
    analytics.reporting.enable = false;
  };
  # Influxdb
  /*services.influxdb = {
    enable = true;
    extraConfig = {
      "reporting-disabled" = true;
      # Expunge collectd dependency, which drags in a crapton of jdk, X, gtk, etc. stuff.
      collectd = [];
      "bind-address" = influx_addr + "8088";
      http."bind-address" = influx_addr +  "8086";
      http.enabled = true;
      http."unix-socket-enabled" = true;
      http."bind-socket" = "/var/local/influxdb/sock";
    };
  };
  systemd.services.influxdb.postStart = lib.mkForce "";*/

  # Fix flake test error at 18.9 by overriding running of borked test cases.
  #nixpkgs.config.packageOverrides = super: {
    # Prometheus fixes
    #python27 = super.python27.override {
      #packageOverrides = python-self: python-super: {
        #pyopenssl = python-super.pyopenssl.overridePythonAttrs (old: { doCheck = false;} );
      #};
    #};
    #prometheus_2 = super.prometheus_2.overrideAttrs (old: { doCheck = false; });
  #};
}
