let
  ssh_pub = import ./ssh_pub.nix;
in {
  userSpecs = [
    ["sh" 1000 ["wheel" "nix-users"] [ssh_pub.sh_allison]]
    ["backup-client" 2000 [] [ssh_pub.root_keiko]]
  ];

  ### Base utilities and libraries
  pkg = pkgs: with pkgs; rec {
    base = [
      glibcLocales

      time
      file
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

      nix-repl

      git
      openssl
      gnupg
    ];

    ### Base documentation
    baseDoc = [
      manpages
      man_db
      posix_man_pages
      libcap_manpages
    ];

    ### Advanced file management
    AFM = [
      gitAndTools.git-annex
    ];

    cliStd = base ++ baseDoc ++ AFM;

    cliDbg = [
      wireshark-cli
    ];

    wifi = [
      wpa_supplicant
      wirelesstools
      networkmanager
    ];

    nixBld = [
      glibc
      binutils
      gcc
      perl
      zlib
    ];
    
    dev = [
      gcc
      gccgo
      ghc
      go
      rustPlatform.rustc

      gnumake
      gdb
      valgrind
    ];

    audio = [
      alsaOss
      alsaPlugins
      alsaUtils
      pulseaudioFull
    ];
    video = [
      mpv
      vlc_qt5
    ];

    ### GUI stuff
    fonts = [
      dejavu_fonts
      unifont
      ttf_bitstream_vera
      
    ];
    
    xorg = with pkgs.xorg; [
      xf86inputsynaptics
      xf86inputevdev
      xf86videointel
      xf86videoati
      xorg_sys_opengl

      xorgserver
      dri2proto
      dri3proto

      xclock
      xdpyinfo
      xinit
      xrandr
      xvinfo
    ];

    guiMisc = [
      gucharmap
    
      clementineFree
      hexchat
      pavucontrol
      anki
    ];

    kdeShared = x: with x; [
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

    kde4 = with pkgs.kde4; (kdeShared pkgs.kde4) ++ [
      kde_baseapps
      kde_base_artwork
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

    kde5 = with pkgs.kde5; (kdeShared pkgs.kde4) ++ [
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

    gui = fonts ++ xorg ++ kde4 ++ guiMisc;
  };

  kernelOpts = {
    base = ''
X86_INTEL_PSTATE n
X86_ACPI_CPUFREQ y
IDE n
'';
  
    blkStd = ''
EXT2_FS y
EXT3_FS y
EXT4_FS y
BTRFS_FS y

DM_CRYPT y
CRYPTO_XTS y

FUSE_FS y
CONFIGFS_FS y
'';

    termHwStd = ''
KEYBOARD_ATKBD y
'';
    # It's typically fine to keep these as modules instead, which NixOS will do by default.
    termVideo = ''
AGP n
I2C_ALGOBIT y
DRM_KMS_HELPER y
DRM y
DRM_I915 y

FRAMEBUFFER_CONSOLE y
FRAMEBUFFER_CONSOLE_DETECT_PRIMARY y
'';
    # This doesn't currently mix well with the default Nix kernel config, since that one forces the conflicting "DRM_LOAD_EDID_FIRMWARE y".
    termHeadless = ''
KEYBOARD_ATKBD y
VT n
DRM n
'';
  };
}
