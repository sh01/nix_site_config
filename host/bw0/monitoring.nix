{ config, pkgs, lib, ... }:
with lib;

let
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
  blackbox_tcp = blackbox_ip + ":9115";
in {
  # Prometheus
  systemd.services.prometheus.script = mkForce "exec ${pkgs.prometheus_2}/bin/prometheus --config.file=${promYml} --storage.tsdb.retention=128y";
  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "32s";
      evaluation_interval = "32s";
      scrape_timeout = "32s";
    };
    scrapeConfigs = [
      {
        job_name = "up0_http";
        scrape_interval = "256s";
        metrics_path = "/probe";
        params = { module = ["http_2xx"]; };
        static_configs = [{targets = ["www.google.com" "www.amazon.com"];}];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = blackbox_tcp; source_labels = [];}
        ];
      } {
        job_name = "node";
        static_configs = [{targets = ["localhost:9100"];}];
      }
    ];
    exporters = {
      blackbox = {
        enable = true;
        configFile = ./mon_p_blackbox.conf;
        listenAddress = blackbox_ip;
      };
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
    package = (pkgs.callPackage ./grafana.nix {});
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
  nixpkgs.config.packageOverrides = super: {
    # Prometheus fixes
    python27 = super.python27.override {
      packageOverrides = python-self: python-super: {
        pyopenssl = python-super.pyopenssl.overridePythonAttrs (old: { doCheck = false;} );
      };
    };
    prometheus_2 = super.prometheus_2.overrideAttrs (old: { doCheck = false; });
  };
}
