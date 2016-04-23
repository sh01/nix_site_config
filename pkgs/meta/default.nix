{pkgs}:
let P = d: {
  type = "derivation";
  deps = d;
}; in with pkgs; rec {
  ### Base utilities and libraries
  base = P [
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

    gzip
    bzip2
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
  baseDoc = P [
    manpages
    man_db
    posix_man_pages
    libcap_manpages
  ];

  ### Advanced file management
  AFM = P [
    gitAndTools.git-annex
  ];

  cliStd = P [base baseDoc AFM];

  cliDbg = P [
    wireshark-cli
  ];

  wifi = P [
    wpa_supplicant
    wirelesstools
    networkmanager
  ];

  nixBld = P [
    glibc
    binutils
    gcc
    perl
    zlib
  ];
    
  dev = P [
    gcc
    gccgo
    ghc
    go
    rustPlatform.rustc

    gnumake
    gdb
    valgrind
  ];

  audio = P [
    alsaOss
    alsaPlugins
    alsaUtils
  ];

  video = P [
    mpv
    vlc_qt5
  ];

  ### GUI stuff
  fonts = P [
    dejavu_fonts
    unifont
    ttf_bitstream_vera    
  ];
    
  xorg = with pkgs.xorg; P [
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
    xinit
    xrandr
    xvinfo
  ];

  # To link directly into lib dirs for use by non-Nix programs
  xlibs = with pkgs.xorg; P [
    libX11
    libXcursor
    libXrandr
  ];

  guiMisc = P [
    redshift
    
    gucharmap
    
    clementineFree
    hexchat
    pavucontrol
    anki
  ];

  kdeShared = x: with x; P [
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

  kde4 = with pkgs.kde4; P [
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

  kde5 = with pkgs.kde5; P [
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

  gui = P [fonts xorg xlibs kde4 guiMisc (import ../kde_conf) (import ../scripts)];
}

