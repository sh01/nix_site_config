{pkgs, lib, stdenv, system}:
let P = bname: d: stdenv.mkDerivation (rec {
    name = "SH_M_" + bname;
    deps = lib.strings.concatStringsSep " " d;
    buildInputs = [pkgs.coreutils];
      unpackPhase = "#";
      buildPhase = ''
        RD="$out/local/_reflinks"
        DD="$out/nix-support"
        mkdir -p "$RD" "$DD"
        echo "${deps}" > "$RD/$name"
        echo "${deps}" > "$DD/propagated-user-env-packages"
'';
    });
in with pkgs; rec {
  emacs_packages = P "emacs_packages" (pkgs.callPackage ../emacs {}).emacsPackages;

  ### Base utilities and libraries
  base = P "base" [
    (pkgs.callPackage ../../default.nix {}).SH_scripts

    glibcLocales

    psmisc
    time
    file
    diffutils
    colordiff
    gnupatch
    less
    most
    hexedit
    screen
    tmux
    tree
    zsh
    iotop
    lsof
    renameutils
    rsync
    strace
    ltrace
    libcap.out
    moreutils
    sshfs-fuse
    binutils #strings
    pv
    fd
    # nix tools
    nvd
    nix-output-monitor
    jq

    emacs_packages

    gzip
    bzip2
    p7zip
    unzip
    xz

    python27
    python3
    python3Packages.pyusb
    bc

    iputils
    ethtool
    netcat
    # nc6
    socat
    tcpdump
    traceroute
    tunctl
    wget
    whois
    ebtables
    nftables
    #(pkgs.callPackage ../nftables-0.9.2/default.nix {})
    iftop
    dnsutils

    acpi
    pciutils
    usbutils
    cpufrequtils
    lm_sensors
    
    mdadm
    gnufdisk
    gptfdisk
    dosfstools
    btrfs-progs
    bcache-tools
    cryptsetup
    smartmontools
    nvme-cli
    multipath-tools
    efibootmgr

    nox

    git
    openssl
    gnupg
  ];

  ### Base documentation
  baseDoc = P "baseDoc" [
    man-pages
    man-db
    posix_man_pages
    libcap.doc
    ascii
  ];

  ### Advanced file management
  AFM = P "AFM" [
    gitAndTools.git-annex
  ];

  cliStd = P "cliStd" [base baseDoc AFM];

  cliDbg = P "cliDbg" [
    # Borked in 24.05
    #wireshark-cli
    stress-ng
  ];

  cliMisc = P "cliMisc" [
    #xonsh # 18.09: Borked.
    which # xonsh startup dependency
  ];
  
  wifi = P "wifi" [
    wpa_supplicant
    wirelesstools
    iw
    firmwareLinuxNonfree
    networkmanager
    networkmanagerapplet
  ];

  nixBld = P "nixBld" [
    stdenv
    ghc
    cmake
  ];
    
  dev = P "dev" [
    gcc
    gccgo
    ghc
    go
    rustc

    gnumake
    gdb
    valgrind
  ];

  audio = P "audio" [
    alsaOss
    alsaPlugins
    alsaUtils
  ];

  video = P "video" [
    mpv
    #vlc
  ];

  ### GUI stuff
  fonts = P "fonts" [
    dejavu_fonts
    unifont
    ttf_bitstream_vera    
  ];
    
  xorg = with pkgs.xorg; P "xorg" [
    xf86inputsynaptics
    xf86inputevdev
    xf86videointel
    xf86videoati
    xorg_sys_opengl

    vulkan-extension-layer
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-tools-lunarg
    vulkan-validation-layers

    xorgserver
    xkeyboard_config
    #dri2proto
    #dri3proto

    xclock
    xdpyinfo
    glxinfo
    xinit
    xrandr
    xvinfo
    xauth
    xhost
    xsecurelock
    xss-lock

    python27Full
    python3Full
  ];

  # To link directly into lib dirs for use by non-Nix programs
  xlibs = with pkgs.xorg; P "xlibs" [
    libX11
    libXcursor
    libXrandr
  ];

  guiMisc = P "guiMisc" [
    redshift
    
    gucharmap
    
    clementine
    hexchat
    pavucontrol
    #anki
  ];

  gamingBox = with (import ../.. {}); P "gamingBox" [
    nixBld
    # Desktop things
    gui
    games
    SH_dep_ggame
    SH_dep_ggame32

    # direct packages
    prometheus
    openntpd
    uptimed
    mpv

    bcachefs-tools
  ];

  kde4 = P "kde4" [
    (kdeShared pkgs.kde4)
    kde_baseapps
    #kde_base_artwork
    plasma-workspace-wallpapers
    plasma-workspace

    amarok
    #digikam #broken on marble

    kdeplasma-addons
    #pykde4
  ];

  kde5 = with pkgs.libsForQt5; P "kde5" [
    kde2-decoration
    kdeFrameworks.kded
    libsForQt5.kdelibs4support
    kdeFrameworks.kdelibs4support
    plasma5.kdecoration

    amarok
    konsole
    kcolorchooser
    kig
    marble
    okular

    kdeplasma-addons
    oxygen
    plasma-desktop
    plasma-workspace
    plasma-workspace-wallpapers
    plasma-workspace-wallpapers
    systemsettings
  ];

  games = P "games" [
    # Borked in 24.05
    #cataclysm-dda
    crawl
    freeorion
    wesnoth
    widelands
    # Borked in 21.11
    #warzone2100
  ];
  
  gui = P "gui" [fonts xorg xlibs guiMisc tilda konsole (import ../kde_conf) (pkgs.callPackage ../scripts {})];


  sys_terminal_wired = P "sys_terminal_wired" [
    cliStd
    nixBld
    cliDbg
    video
    audio
    gui
    cliMisc
  ];
  sys_terminal = P "sys_terminal" [
    sys_terminal_wired
    wifi
  ];
}

