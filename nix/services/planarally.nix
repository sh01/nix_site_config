{ name, port, ugid, pkgs, ... }: let
  uname = "planarally_${name}";
  PA = (pkgs.callPackage ../pkgs {}).planarally;
  homedir = "/var/local/planarally/${name}";
  rundir = "${homedir}/pa_state";

  conf = builtins.toFile "server_config.cfg" ''
[Webserver]
host = 127.0.0.2
port = ${toString port}
max_upload_size_in_bytes = 10_485_760
ssl = false
[General]
save_file = db.sqlite
assets_directory = ./assets
max_log_size_in_bytes = 262_144
max_log_backups = 5
allow_signups = true
enable_export = true
[APIserver]
enabled = false
'';
  
  confPkg = (pkgs.stdenv.mkDerivation {
    name = "local_pa_config_${name}";
    phases = ["installPhase"];
    installPhase = ''
      od="$out/share/local/planarally/${name}"
      mkdir -p "$od"
      ln -s "${conf}" "$od/server_config.cfg"
    '';
  });

in {
  users.users."${uname}" = {
    uid = ugid;
    group = "${uname}";
    isSystemUser = true;
    description = "planarally";
    home = homedir;
    createHome = true;
  };
  users.groups."${uname}" = {
    gid = ugid;
  };

  environment.systemPackages = [ confPkg ];

  systemd.services."local_planarally_${name}" = {
    description = "Locally configured planarally instance.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    #path = with pkgs; [];
    serviceConfig = {
      User = uname;
      Group = uname;
      Restart = "on-failure";
    };
    script = ''
      # config: ${confPkg}
      mkdir -p "${rundir}/static"
      cd "${rundir}"
      exec ${PA}/bin/run_planarally.py --rundir "${rundir}"
    '';
  };
}
