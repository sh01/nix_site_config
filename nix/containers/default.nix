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
  mpkgs = pkgs.callPackage ../pkgs/pkgs/meta {};
in rec {
  sysPkgsBase = with pkgs; with (pkgs.callPackage ../pkgs/pkgs/meta {}); [
    base
    less
    file
    zsh
    hexedit
    lsof
    unzip
    binutils
    patchelf
    screen
    strace
    tmux
    git
    python3
    mpkgs.emacs_packages
    psmisc
  ];
  sysPkgsPrsw = sysPkgsBase ++ (with lpkgs; [
    SH_dep_ggame
    SH_dep_ggame32
    wine
    # Binaries used by libs
    pkgs.xorg.xrandr
    gnome3.zenity
    xdg_utils
    xdg-user-dirs
  ]);

  gpuAllow = {
    allowedDevices = [{
      modifier = "rw";
      node = "char-drm";
    }];
  };

  c = rks: uks: {
    browsers = {
      config = (import ./browsers.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsBase;};
      autoStart = true;
      bindMounts = {
        "/home/browsers" = {
          hostPath = "/home/browsers";
          isReadOnly = false;
        };
      } // bbMounts;
    } // (net "2");
    prsw = {
      config = (import ./prsw.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/prsw" = {
	  hostPath = "/home/prsw";
	  isReadOnly = false;
        };
      } // bbMounts // gpuMounts;
    } // gpuAllow // (net "3");
    "prsw-net" = {
      config = (import ./prsw.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/prsw_net" = {
	  hostPath = "/home/prsw_net";
	  isReadOnly = false;
	};
      } // bbMounts // gpuMounts;
    } // gpuAllow // (net "4");
  };
  
  termC = ssh_pub: with (c [ssh_pub.root] [ssh_pub.sh]); {
    browsers = browsers;
    prsw = prsw;
    "prsw-net" = prsw-net;
  };

  # TODO-maybe: Add some more functional way to derive this config.
  sshConfig = ''
Host cbrowser
HostName 10.231.1.2
SendEnv DISPLAY
#User cbrowser_sh
  
Host prsw
HostName 10.231.1.3
SendEnv DISPLAY
#User prsw_sh

Host prsw_net
HostName 10.231.1.4
SendEnv DISPLAY
#User prsw_net_sh
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
