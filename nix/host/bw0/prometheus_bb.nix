{ pkgs, user, listen }: let
  configFile = ./mon_p_blackbox.conf;
in {
  serviceConfig = {
    User = user;

    AmbientCapabilities = [ "CAP_NET_RAW" ]; # for ping probes
    ExecStart = ''
       ${pkgs.prometheus-blackbox-exporter}/bin/blackbox_exporter \
       --web.listen-address ${listen} \
       --config.file ${configFile}
     '';
     ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
   };
  after = ["network.target"];
  wantedBy = ["multi-user.target"];
}
