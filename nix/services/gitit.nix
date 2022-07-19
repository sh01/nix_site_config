{ name, port, ugid, pkgs, ... }: let
  uname = "wiki_${name}";
  homedir = "/home/www/wiki/${name}";
  configFile = pkgs.writeText "gitit.conf" ''
    host: 127.0.0.2
    port: ${toString port}
    repository-type: git

    wiki-title: ${name}
    default-page-type: Org
    authentication-method: http
    max-upload-size: 32M

    front-page: front
    no-delete: front, Help
    no-edit:
  '';
  gititWithPkgs = pkgs.haskellPackages.ghcWithPackages (self: [ self.gitit self ]);
in rec {
  users.users."${uname}" = {
    uid = ugid;
    group = "${uname}";
    isSystemUser = true;
    description = "gitit";
    home = homedir;
    createHome = true;
  };
  users.groups."${uname}" = {
    gid = ugid;
  };
  systemd.services."local_gitit_${name}" = {
    description = "Locally configured gitit instance";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ git ];
    serviceConfig = {
      User = uname;
      Group = uname;
      ExecStart = pkgs.writeScript "gitit.sh" ''
        #!${pkgs.bash}/bin/sh
        cd $HOME
        export NIX_GHC="${gititWithPkgs}/bin/ghc"
        export NIX_GHCPKG="${gititWithPkgs}/bin/ghc-pkg"
        export NIX_GHC_DOCDIR="${gititWithPkgs}/share/doc/ghc/html"
        export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
        exec ${gititWithPkgs}/bin/gitit -f ${configFile}
      '';
    };
  };
}
