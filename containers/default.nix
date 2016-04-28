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
  gpuMounts = {
    "/dev/dri" = {
      hostPath = "/dev/dri";
      isReadOnly = true;
    };
  };
  net = num: {
    hostAddress = "10.231.1.1";
    localAddress = "10.231.1." + num;
    privateNetwork = true;
  };
in rec {
  ## Remember to also edit scripts->setup_container_route if you add to the network config here.
  # TODO-maybe: Add some more elegant config mechanism.
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
    } // (net "2");
    prsw = {
      config = ((import ./prsw.nix) rk uk);
      autoStart = true;
      bindMounts = {
        "/home/sh_prsw" = {
	  hostPath = "/home/sh_prsw";
	  isReadOnly = false;
	};
      } // bbMounts // gpuMounts;
    } // (net "3");
  };
  
  termC = ssh_pub: with (c [ssh_pub.root] [ssh_pub.sh]); {
    browsers = browsers;
    prsw = prsw;
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
