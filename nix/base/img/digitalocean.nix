{config, lib, pkgs, ...}: {
  system.build.digitalOceanImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib pkgs config;
    name = "digital-ocean-image";
    format = "qcow2";
    copyChannel = false;
    contents = [
      {source=/etc/site; target="/etc/site";}
    ];
  };
  virtualisation.digitalOcean = {
    # This is just asking for problems.
    rebuildFromUserData = false;
    setSshKeys = false;
    defaultConfigFile = "__invalid__";
  };
  systemd.services.SH_do_pre = rec {
    wantedBy = ["digitalocean-metadata.service"];
    before = wantedBy;
    path = [pkgs.iproute];
    script = ''
    ip addr replace 169.254.169.15/24 dev eth0
    '';
    serviceConfig = {
      Restart = "on-failure";
      RemainAfterExit = "yes";
    };
  };
  systemd.services.do-agent.wantedBy = lib.mkForce [];
}
