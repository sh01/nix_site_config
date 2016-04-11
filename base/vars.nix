let
  ssh_pub = import ./ssh_pub.nix;
  pkgs = import <nixpkgs> {};
in rec {
  userSpecs = [
    ["sh" 1000 ["wheel" "nix-users"] [ssh_pub.sh_allison]]
    ["backup-client" 2000 [] [ssh_pub.root_keiko]]
  ];

  ### Base utilities and libraries
  pkBase = with pkgs; [
    glibcLocales

    file
    less
    most
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
  pkBaseDoc = with pkgs; [
    manpages
    man_db
    posix_man_pages
    libcap_manpages
  ];

  ### Advanced file management
  pkAFM = with pkgs; [
    gitAndTools.git-annex
  ];

  pkCLIStd = pkBase ++ pkBaseDoc ++ pkAFM;

  pkCLIDbg = with pkgs; [
    wireshark-cli
  ];

  pkWifi = with pkgs; [
    wpa_supplicant
    wirelesstools
    networkmanager
  ];
}
