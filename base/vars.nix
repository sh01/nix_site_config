let
  ssh_pub = import ./ssh_pub.nix;
  pkgs = import <nixpkgs> {};
in {
  userSpecs = [
    ["sh" 1000 ["wheel" "nix-users"] [ssh_pub.sh_allison]]
    ["backup-client" 2000 [] [ssh_pub.root_keiko]]
  ];

  ### Base utilities and libraries
  pkg = rec {
    base = with pkgs; [
      glibcLocales

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
      gnupg
    ];

    ### Base documentation
    baseDoc = with pkgs; [
      manpages
      man_db
      posix_man_pages
      libcap_manpages
    ];

    ### Advanced file management
    AFM = with pkgs; [
      gitAndTools.git-annex
    ];

    cliStd = base ++ baseDoc ++ AFM;

    cliDbg = with pkgs; [
      wireshark-cli
    ];

    wifi = with pkgs; [
      wpa_supplicant
      wirelesstools
      networkmanager
    ];
  };

  kernelOpts = {
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
