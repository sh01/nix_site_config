{pkgs, lib, ...}:
let
  bbMounts = {
    "/tmp/.X11-unix" = {
      isReadOnly = true;
    };
    #"/run/users" = {
    #  hostPath = "/run/users";
    #  isReadOnly = true;
    #};
    "/home/stash".isReadOnly = true;
    "/run/pulse".isReadOnly = false;
  };
  devMounts = {
    "/dev/dri".isReadOnly = true;
    "/dev/input".isReadOnly = true;
    "/run/udev/data".isReadOnly = true;
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
    SH_dep_ggame_rg
    SH_dep_ggame32
    SH_dep_ggame32_rg
    
    wine64Packages.fonts
    winePackages.fonts
    wine64Packages.stableFull
    winePackages.stableFull

    # Minecraft 1.12.2
    SH_dep_java8
    # Minecraft 1.18.2
    SH_dep_java17

    winetricks
    vulkan-loader
    vulkan-tools
    # Binaries used by libs
    pkgs.xorg.xrandr
    gnome3.zenity
    xdg_utils
    xdg-user-dirs
  ]);

  devAllow = {
    allowedDevices = [
      { modifier = "rw"; node = "char-drm";}
      # Joysticks/pad(-likes)
      # Potentially dangerously broad, but we have to for now.
      { modifier = "r"; node = "char-input";}
      # More specific variant of the above; ineffective as of 2022-10-15 (systemd bugs?)
      { modifier = "rw"; node = "/dev/input/js*";}
      { modifier = "rw"; node = "/dev/input/by-id/*_Controller_*";}
      { modifier = "rw"; node = "/dev/input/by-id/*joystick";}
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
    } // devAllow // (net "3");
    "prsw-net" = {
      config = (import ./prsw.nix) {inherit pkgs rks uks; sysPkgs = sysPkgsPrsw;};
      autoStart = true;
      bindMounts = {
        "/home/prsw_net" = {
	  hostPath = "/home/prsw_net";
	  isReadOnly = false;
	};
      } // bbMounts // devMounts;
    } // devAllow // (net "4");
  };

  c_vpn = rec {
    upAddr = (net "1").localAddress;
    vNet = (net "5");
    vAddr = vNet.localAddress;
    cNet = (net "6");
    cAddr = cNet.localAddress;
    brDev = "lc_br_vu";
    cont = inCfg: {
      "vpn-up" = {
        config = (import ./vpn_up.nix {inherit lib pkgs cAddr; sysPkgs = sysPkgsBase;});
        enableTun = true;
        autoStart = true;
        hostBridge = brDev;
      } // vNet;
      "vpn-in" = {
        config = (import ./vpn_in.nix {inherit lib pkgs upAddr vAddr; sysPkgs = sysPkgsBase;}) // inCfg;
        autoStart = true;
        hostBridge = brDev;
      } // cNet;
    };

    br = {
      "${brDev}" = { interfaces = [];};
    };

    ifaces."${brDev}".ipv4 = {
      addresses = [{address = upAddr; prefixLength = 32; }];
      routes = [
        { address = vAddr; prefixLength = 32;}
        { address = cAddr; prefixLength = 32;}
      ];
    };
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
