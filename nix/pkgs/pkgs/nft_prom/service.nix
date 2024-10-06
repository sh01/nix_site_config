{ pkgs, ... }:
let
  nft_prom = pkgs.callPackage ./default.nix {};
in {
  systemd.services.nft_prom = {
    wantedBy = [ "prometheus.service" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Restart = "always";
      WorkingDirectory="/var/empty";
      ExecStart = "${nft_prom}/bin/nft_prom.py --port 9102";
    };
  };
}
