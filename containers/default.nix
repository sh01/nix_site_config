{pkgs}:
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
  lpkgs = pkgs.callPackage ../pkgs {};
in rec {
  sysPkgsBase = with pkgs; [
    less
    file
    zsh
    hexedit
    unzip
    binutils
    patchelf
    screen
    tmux
    git
    python
  ];
  sysPkgsPrsw = sysPkgsBase ++ (with lpkgs; [
    SH_dep_mc0
    SH_dep_factorio
    SH_dep_KSP
    SH_dep_CK2
    SH_dep_ggame
    SH_dep_ggame32
    pkgs.xorg.xrandr
  ]);

  c = rks: uks: {
    browsers = {
      config = (import ./browsers.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsBase;};
      autoStart = true;
      bindMounts = {
        "/home/sh_cbrowser" = {
          hostPath = "/home/sh_cbrowser";
          isReadOnly = false;
        };
      } // bbMounts;
    } // (net "2");
    prsw = {
      config = (import ./prsw.nix) {inherit rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/sh_prsw" = {
	  hostPath = "/home/sh_prsw";
	  isReadOnly = false;
	};
      } // bbMounts // gpuMounts;
    } // (net "3");
    prsw_net = {
      config = (import ./prsw.nix) {inherit rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/sh_prsw_net" = {
	  hostPath = "/home/sh_prsw_net";
	  isReadOnly = false;
	};
      } // bbMounts // gpuMounts;
    } // (net "4");
  };
  
  termC = ssh_pub: with (c [ssh_pub.root] [ssh_pub.sh]); {
    browsers = browsers;
    prsw = prsw;
    prsw_net = prsw_net;
  };

  # TODO-maybe: Add some more functional way to derive this config.
  sshConfig = ''
Host sh_cbrowser
HostName 10.231.1.2
SendEnv DISPLAY
User sh_cbrowser
  
Host sh_prsw
HostName 10.231.1.3
SendEnv DISPLAY
User sh_prsw

Host sh_prsw_net
HostName 10.231.1.4
SendEnv DISPLAY
User sh_prsw_net
'';
  
  # Systemd service setup
  termS = {
    SH_containers_sh = {
      wantedBy = ["container@browsers.service" "container@prsw.service" "container@prsw_net.service"];
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
