let
  lpkgs = (import ../.. {});
in {
  systemd.services.nft_prom = {
    wantedBy = [ "prometheus.service" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Restart = "always";
      WorkingDirectory="/var/empty";
      ExecStart = "${lpkgs.nft_prom}/bin/nft_prom.py --port 9101";
    };
  };
}
