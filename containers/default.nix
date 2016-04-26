let
  bbMounts = {
    "/tmp/.X11-unix" = {
      hostPath = "/tmp/.X11-unix";
      isReadOnly = true;
    };
    "/run/users" = {
      hostPath = "/run/users";
      isReadOnly = true;
    };
  };
in rec {
  c = rk: uk: {
    browsers = {
      config = ((import ./browsers.nix) rk uk);
      autoStart = true;
      bindMounts = {
        "/home/sh_cbrowser" = {
          hostPath = "/home/sh_cbrowser";
          isReadOnly = false;
        };
      } // bbMounts;
      privateNetwork = true;
      hostAddress = "10.231.1.1";
      localAddress = "10.231.1.2";
    };
  };
  
  termC = ssh_pub: {
    browsers = (c [ssh_pub.root] [ssh_pub.sh]).browsers;
  };

  # Systemd service setup
  termS = {
    SH_containers_sh = {
      wantedBy = ["all-containers.service"];
      description = "SH_containers_sh";
      script = ''
# Set up container dirs
mkdir -p /run/users/sh_x/pulse
chown -R sh:sh_x /run/users/sh_x/
chmod g+rx,o-rx -R /run/users/sh_x
'';
    };
  };
}
