{pkgs, system}:
let P = name: d: derivation {
  name = "SH_M_" + name;
  system = system;
  coreutils = pkgs.coreutils;
  builder = ./store_pue;
  propagatedUserEnvPkgs = d;
}; in with pkgs; rec {
  emacs_packages = P "emacs_packages" (pkgs.callPackage ../emacs {}).emacsPackages;

  ### Base utilities and libraries
  base = P "base" [
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
    tree
    zsh
    iotop
    lsof
    rsync
    strace
    ltrace
    libcap_progs
    moreutils

    emacs_packages

    gzip
    bzip2
    p7zip
    unzip
    xz
 
    python
    python3

    iputils
    ethtool
    netcat
    socat
    tcpdump
    wget
    ebtables
    nftables
    iftop

    acpi
    pciutils
    usbutils
    cpufrequtils
    
    mdadm
    gnufdisk
    gptfdisk
    dosfstools
    btrfsProgs
    bcache-tools
    cryptsetup
    smartmontools
    multipath-tools

    nix-repl
    nox

    git
    openssl
    gnupg
  ];

  ### Base documentation
  baseDoc = P "baseDoc" [
    manpages
    man_db
    posix_man_pages
    libcap_manpages
  ];

  ### Advanced file management
  AFM = P "AFM" [
    gitAndTools.git-annex
  ];

  cliStd = P "cliStd" [base baseDoc AFM];

  cliDbg = P "cliDbg" [
    wireshark-cli
  ];

  wifi = P "wifi" [
    wpa_supplicant
    wirelesstools
    networkmanager
  ];

  nixBld = P "nixBld" [
    glibc
    binutils
    gcc
    perl
    perl522
    zlib
  ];
    
  dev = P "dev" [
    gcc
    gccgo
    ghc
    go
    rustPlatform.rustc

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
    vlc_qt5
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

    xorgserver
    xkeyboard_config
    dri2proto
    dri3proto

    xclock
    xdpyinfo
    glxinfo
    xinit
    xrandr
    xvinfo
    xauth
    xhost
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
    
    clementineFree
    hexchat
    pavucontrol
    anki
  ];

  kdeShared = x: with x; P "kdeShared" [
    kate
    kcolorchooser
    kdepim #akregator
    kig
    kmix
    konsole
    kwin_styles
    marble
      
    okular
  ];

  kde4 = with pkgs.kde4; P "kde4" [
    (kdeShared pkgs.kde4)
    kde_baseapps
    #kde_base_artwork
    kde_wallpapers
    kde_workspace

    amarok
    digikam

    yakuake

    kdeplasma_addons
    ColorSchemes
    desktopthemes
    pykde4
  ];

  kde5 = with pkgs.kde5; P "kde5" [
    (kdeShared pkgs.kde5)
    kde-baseapps
    kde-cli-tools
    kde-base-artwork
    kde-wallpapers
    kde-workspace
    kwin

    oxygen
    plasma-desktop
    plasma-workspace-wallpapers
    systemsettings
  ];

  games = P "games" [
    cataclysm-dda
    crawl
    #freeorion #doesn't exist yet
    wesnoth
    widelands
    warzone2100
  ];
  
  gui = P "gui" [fonts xorg xlibs kde4 guiMisc (import ../kde_conf) (pkgs.callPackage ../scripts {})];

  sys_terminal = P "sys_terminal" [
    cliStd
    nixBld
    cliDbg
    wifi
    dev
    video
    audio
    gui
  ];
}

