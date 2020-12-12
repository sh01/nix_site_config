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
    (import ../../default.nix {}).SH_scripts

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
    rsync
    strace
    ltrace
    libcap_progs
    moreutils
    sshfsFuse
    binutils #strings
    pv

    emacs_packages

    gzip
    bzip2
    p7zip
    unzip
    xz
 
    pythonFull
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
    wget
    whois
    ebtables
    #nftables
    (pkgs.callPackage ../nftables-0.9.2/default.nix {})
    iftop
    dnsutils

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
    ascii
  ];

  ### Advanced file management
  AFM = P "AFM" [
    gitAndTools.git-annex
  ];

  cliStd = P "cliStd" [base baseDoc AFM];

  cliDbg = P "cliDbg" [
    wireshark-cli
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

  kde4 = P "kde4" [
    (kdeShared pkgs.kde4)
    kde_baseapps
    #kde_base_artwork
    plasma-workspace-wallpapers
    plasma-workspace

    amarok
    #digikam #broken on marble

    yakuake

    kdeplasma-addons
    #pykde4
  ];

  kde5 = with pkgs.kdeApplications; P "kde5" [
    kde2-decoration
    kdeFrameworks.kded
    libsForQt5.kdelibs4support
    kdeFrameworks.kdelibs4support
    plasma5.kdecoration

    amarok
    yakuake
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
    cataclysm-dda
    crawl
    freeorion
    wesnoth
    widelands
    warzone2100
  ];
  
  gui = P "gui" [fonts xorg xlibs kde5 guiMisc (import ../kde_conf) (pkgs.callPackage ../scripts {})];


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

