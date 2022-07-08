{pkgs}:
let
  bbMounts = {
    "/tmp/.X11-unix" = {
      hostPath = "/tmp/.X11-unix";
      isReadOnly = true;
    };
    #"/run/users" = {
    #  hostPath = "/run/users";
    #  isReadOnly = true;
    #};
    "/home/stash" = {
      hostPath = "/home/stash";
      isReadOnly = true;
    };
    "/run/pulse" = {
      hostPath = "/run/pulse";
      isReadOnly = false;
    };
  };
  devMounts = {
    "/dev/dri" = {
      hostPath = "/dev/dri";
      isReadOnly = true;
    };
    "/dev/input" = {
      hostPath = "/dev/input";
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
    wine64Packages.fonts
    winePackages.fonts
    wine64Packages.stableFull
    winePackages.stableFull
    #wine
    #wine64
    winetricks
    vulkan-loader
    vulkan-tools
    # Binaries used by libs
    pkgs.xorg.xrandr
    gnome3.zenity
    xdg_utils
    xdg-user-dirs
  ]);

  gpuAllow = {
    allowedDevices = [
      { modifier = "rw"; node = "char-drm";}
      # Microsoft xbox core controller
      { modifier = "rwm"; node = "/dev/input/js0";}
      { modifier = "rwm"; node = "/dev/input/by-id/usb-Microsoft_Controller_3039373133383636303934313235-event-joystick";}
      { modifier = "rwm"; node = "/dev/input/by-id/usb-Microsoft_Controller_3039373133383636303934313235-joystick";}
    ];
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
      } // bbMounts // devMounts;
    } // gpuAllow // (net "3");
    "prsw-net" = {
      config = (import ./prsw.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/prsw_net" = {
	  hostPath = "/home/prsw_net";
	  isReadOnly = false;
	};
      } // bbMounts // devMounts;
    } // gpuAllow // (net "4");
  };
  
  termC = ssh_pub: with (c [ssh_pub.root] ssh_pub.cont_users); {
    browsers = browsers;
    prsw = prsw;
    "prsw-net" = prsw-net;
  };

  # TODO-maybe: Add some more functional way to derive this config.
  sshConfig = ''
Host cbrowser
HostName 10.231.1.2
SendEnv DISPLAY
  
Host prsw
HostName 10.231.1.3
SendEnv DISPLAY

Host prsw_net
HostName 10.231.1.4
SendEnv DISPLAY
'';
  
  # Systemd service setup
  termS = {
    SH_containers_sh = {
      wantedBy = ["container@browsers.service" "container@prsw.service" "container@prsw_net.service" "pulseaudio.service"];
      before = ["pulseaudio.service"];
      script = ''
# Work around https://github.com/NixOS/nixpkgs/issues/114399 :
# Reset pulse homedir to fix permissions if they're incorrect.
D=/run/pulse
ls -dl1 "$D" | grep -q '^d...r.x' || rm -rf "$D"
'';
    };
  };
}
