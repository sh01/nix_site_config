{ config, pkgs, lib, l, ... }:
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
  nft_configs = [{targets = ["localhost:9102"];}];
  _node_configs = port: [{targets = map (x: x + ":" + (toString port)) ["localhost" "jibril.x.s." "yalda.sh.s." "liel.x.s." "uiharu.sh.s."];}];
  node_configs = port:
    let
      hConfig = hn:
        let
          lh = hn == "localhost";
          hAddr = if lh then "::1" else l.hostsTable."${hn}".net.addr.c_wg0;
          ins = if lh then l.hostname else hn;
        in {
          targets = ["[${hAddr}]:${toString port}"];
          labels.instance = ins;
        };
    in map hConfig ["localhost" "jibril" "yalda" "liel" "uiharu" "ika"];
in rec {
  imports = [
    ../../pkgs/pkgs/nft_prom/service.nix
    ../../services/prom_exp_node.nix
  ];
  # Prometheus
  systemd.services = {
    #prometheus.script = mkForce "exec ${pkgs.prometheus}/bin/prometheus --config.file=${promYml} --storage.tsdb.retention=128y";
    "prometheus-blackbox-exporter-0" = prom_bb {inherit pkgs; listen="127.0.0.1:9115"; user="mon_0";};
    "prometheus-blackbox-exporter-1" = prom_bb {inherit pkgs; listen="127.0.0.1:9116"; user="mon_1";};
  };

  services.prometheus = {
    enable = true;
    retentionTime = "128y";
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
        static_configs = (node_configs 9100);
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
      } {
        job_name = "jibril_mc0";
        scrape_interval = "64s";
        static_configs = [{ targets = ["jibril.x.s:20004"]; }];
        metric_relabel_configs = [
          {
            source_labels = ["__name__"];
            regex = "process_.*|jvm_(classes_currently_loaded|buffer_pool_used_bytes|memory_bytes_committed)|mc_(entities_total|server_tick_seconds_(count|sum)|dimension_chunks_loaded|dimension_tick_seconds_(count|sum)|player_list)";
            action = "keep";
          }
        ];
      } {
        job_name = "smartctl";
        scrape_interval = "256s";
        static_configs = (node_configs 9101);
        metric_relabel_configs = [{
          source_labels = ["__name__"];
          regex = "smartctl_device(|_available_spare|_block_size|_bytes_read|_bytes_written|_capacity_blocks|_critical_warning|_media_errors|_power_cycle_count|_power_on_seconds|_smart_status|_temperature|_version)$";
          action = "keep";
       }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;
      "auth.anonymous" = {
        enabled = true;
        org_name = "main";
      };
      users.allow_sign_up = false;
      server.http_addr = "0.0.0.0";
    };
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
}
