{config, lib, pkgs, ...}:
let
  ssh_pub = import ./ssh_pub.nix;
  # Recursively read all files from ./etc and build an environment.etc value.
  med = let bp = (builtins.toString ../../etc); in p: if p == "" then bp else bp  + "/" + p;
  pdir = (p:
  let
    dd = (builtins.readDir (builtins.toPath (med p)));
  in
    builtins.foldl' (x: y: x // y) {} (map (n:
    let
      fp = (builtins.toPath (med sp));
      sp = (p + "/" + n);
    in
      if dd."${n}" == "directory"
      then (pdir sp)
      else { "${sp}" = { text = (builtins.readFile fp); }; })
    (builtins.attrNames dd)
  ));
in rec {
  environment.etc = pdir ".";

  imports = [
    ./channel.nix
  ];
  
  environment.shells = [ "/run/current-system/sw/bin/zsh" ];
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  security = {
    sudo.execWheelOnly = true;
    pam.services = {
      su.requireWheel = true;
      sudo.requireWheel = true;
    };
    # needed for nix sandboxing, unfortunately.
    # allowUserNamespaces = false;
  };
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
  
  environment.shellAliases = {
    grep = "grep --color=auto";
    ls = "ls --color=auto --time-style=long-iso";
    hd = "hexdump -C";
    he = "hexedit --color";

    ne = "PAGER=cat nix-env";
    ns = "PAGER=cat nix-store";
    nix = "PAGER=cat nix";
    
    jctl = "journalctl -o short-iso";

    mp2mca = "mplayer2 -af resample=48000:1:2,hrtf -channels 6";
    ga = "git-annex";
  };

  # Local package includes.
  environment.pathsToLink = ["/local" "/share/local"];
  
  programs.zsh = {
    enable = true;
    shellAliases = environment.shellAliases // {
      h = "fc -l -i 0";
    };
    interactiveShellInit = "source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
    shellInit = (builtins.readFile ./shell_env.sh);
    histFile = "$XDG_STATE_HOME/zsh/history";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # We don't need this.
    grub2 = pkgs.grub2.override { zfsSupport = false; };
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { guiSupport = false; };

    # Put procps below coreutils for uptime(1).
    procps = pkgs.lib.hiPrio pkgs.procps;
    # Add postgres support to dspam.
    dspam = pkgs.dspam.override { withPgSQL = true; postgresql=pkgs.postgresql96; };
    # Take configs from /etc/ircd so we can override MOTD files.
    #charybdis = pkgs.stdenv.lib.overrideDerivation pkgs.charybdis (a: {
    #  configureFlags = a.configureFlags ++ ["--sysconfdir=/etc/ircd"];
    #});
  };

  ##### Internationalisation properties
  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" "en_IE.UTF-8/UTF-8" "en_US/ISO-8859-1" "en_DK/ISO-8859-1" "en_IE/ISO-8859-1" "en_IE@euro/ISO-8859-15" ];
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services = {
    logind = {
      lidSwitch = "lock";
      extraConfig = ''
        KillUserProcesses=no'';
    };
    cron.enable = true;

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    # NTP
    timesyncd.enable = false;
    chrony = {
      #enable = true;
    };
    gvfs.package = pkgs.gvfs.override { gnomeSupport = false; };
    xserver = {
      enableCtrlAltBackspace = true;
      videoDrivers = ["intel"];
      # Logitech Marble tweaks
      extraConfig = ''
      Section "InputClass"
        Identifier "Logitech USB Trackball"
        Driver "libinput"
        Option "ButtonMapping" "1 0 3 4 5 6 7 0 2"
        Option "ScrollMethod" "button"
        Option "ScrollButton" "8"
        Option "HorizontalScrolling" "false"
      EndSection
'';
    };
  };

  #### Nixpkgs
  nixpkgs.config.allowUnfree = false;
  nixpkgs.config.permittedInsecurePackages = [ "python-2.7.18.7" "python-2.7.18.8" ];

  ##### Nix source and build config
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      require-sigs = true;
      trusted-public-keys = lib.mkForce [];
      trusted-substituters = lib.mkForce [];
      #use-xdg-base-directories = true;
      # Nix is currently aggravating about not accepting empty values here: https://github.com/NixOS/nix/blob/master/scripts/download-from-binary-cache.pl.in#L240
      # Give it one that allows it to fail-fast, instead.
      substituters = lib.mkForce ["file:///var/local/nix/cache"];
      hashed-mirrors = ["https://tarballs.nixos.org"];
      # Enable easy rebuilding
      keep-outputs = true;

      cores = 0;
      allowed-users = [ "@nix-users" ];
    };
    #daemonIONiceLevel = 2;
    #daemonNiceLevel = 2;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    extraOptions = ''
keep-env-derivations = true
substitute = false
build-use-substitutes = false
trusted-public-keys = foo:uX203jWszivwkcB7Ig0EjJKnu38oIgbNw01e1M4GGtI=
'';
  };
  #### Nix setup scripts
  system.activationScripts = {
    cache_perms = lib.stringAfter ["users" "groups"] ''
git=${pkgs.git}/bin/git
if [ -d /var/cache/ ]; then
  chmod go+rx /var/cache
  BD=/var/cache/nix_mirror
  if [ -d "$BD" ]; then
    D="$BD/tar"
    if [ ! -d "$D" ]; then
      mkdir -p "$D"
      chown nix_mirror:nix_mirror "$D"
    fi

    for SD in site nixpkgs; do
      D="$BD/$SD"
      if [ ! -d "$D" ]; then
        mkdir "$D"
        cd "$D"
        $git init --bare
        chown -R nix_mirror:nix_mirror "$D"
      fi
    done
  fi
fi
'';
  };
    
  #### Nix firewall
  networking = {
    # Doesn't work right on other hosts due to use of static ifaces.
    nftables.checkRuleset = false;

    usePredictableInterfaceNames = false;
    useNetworkd = false;
    firewall = {
      allowPing = true;
      rejectPackets = true;
    };
    # Prevent dangerous distri hosts from being contacted.
    extraHosts = "127.255.0.1 cache.nixos.org";
  };

  #### Per-program config
  programs.ssh.startAgent = false;
  programs.ssh.knownHosts = ssh_pub.knownHosts;

  ######## X-windows things
  fonts.fontconfig.defaultFonts.serif = [ "DejaVu Sans" ];
  #### Docs
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
