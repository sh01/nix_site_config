{config, pkgs, ...}: let
  ssh_pub = import ./ssh_pub.nix;
in rec {
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
    "zshenv.local" = {
      text = (builtins.readFile ./etc/zshenv.local);
    };
    "DIR_COLORS" = {
      text = (builtins.readFile ./etc/DIR_COLORS);
    };
    "xdg/user-dirs.defaults" = {
      text = (builtins.readFile ./etc/xdg/user-dirs.defaults);
    };
  };

  imports = [
    ./channel.nix
    ./emacs
  ];

  environment.shells = [ "/run/current-system/sw/bin/zsh" ];
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
  
  environment.shellAliases = {
    grep = "grep --color=auto";
    ls = "ls --color=auto --time-style=long-iso";
    hd = "hexdump -C";
    he = "hexedit --color";

    ne = "PAGER=cat nix-env";
    ns = "PAGER=cat nix-store";

    mp2mca = "mplayer2 -af resample=48000:1:2,hrtf -channels 6";
    ga = "git-annex";
  };

  programs.zsh = {
    enable = true;
    shellAliases = environment.shellAliases // {
      h = "fc -l -i 0";
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # We don't need this.
    grub2 = pkgs.grub2.override { zfsSupport = false; };
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { x11Support = false; };

    # Put procps below coreutils for uptime(1).
    procps = pkgs.lib.hiPrio pkgs.procps;
  };

  
  ##### Internationalisation properties
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };
  ####
  services.logind.extraConfig = "HandleLidSwitch=ignore";
  #### Nixpkgs
  nixpkgs.config.allowUnfree = false;
  
  ##### Nix source and build config
  nix = {
    allowedUsers = [ "@nix-users" ];
    binaryCachePublicKeys = [];
    binaryCaches = [];
    buildCores = 0;
    requireSignedBinaryCaches = true;
    daemonIONiceLevel = 2;
    daemonNiceLevel = 2;
  };
    
  #### Nix firewall
  networking.firewall.allowPing = true;
  networking.firewall.rejectPackets = true;

  #### Per-program config
  programs.ssh.startAgent = false;
  programs.ssh.knownHosts = ssh_pub.knownHosts;

  ######## X-windows things
  fonts.fontconfig.defaultFonts.serif = [ "DejaVu Sans" ];
}
