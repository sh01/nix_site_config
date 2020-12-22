{config, lib, pkgs, ...}:
let
  ssh_pub = import ./ssh_pub.nix;
  # Recursively read all files from ./etc and build an environment.etc value.
  med = let bp = (builtins.toString ./etc); in p: if p == "" then bp else bp  + "/" + p;
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
  
  environment.shellAliases = {
    grep = "grep --color=auto";
    ls = "ls --color=auto --time-style=long-iso";
    hd = "hexdump -C";
    he = "hexedit --color";

    ne = "PAGER=cat nix-env";
    ns = "PAGER=cat nix-store";
    
    jctl = "journalctl -o short-iso";

    mp2mca = "mplayer2 -af resample=48000:1:2,hrtf -channels 6";
    ga = "git-annex";
  };

  # Local package includes.
  environment.pathsToLink = ["/local"];

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
    gnupg = pkgs.gnupg.override { guiSupport = false; };

    # Put procps below coreutils for uptime(1).
    procps = pkgs.lib.hiPrio pkgs.procps;
    # Add postgres support to dspam.
    dspam = pkgs.dspam.override { withPgSQL = true; postgresql=pkgs.postgresql96; };
    # Take configs from /etc/ircd so we can override MOTD files.
    charybdis = pkgs.stdenv.lib.overrideDerivation pkgs.charybdis (a: {
      configureFlags = a.configureFlags ++ ["--sysconfdir=/etc/ircd"];
    });
  };

  
  ##### Internationalisation properties
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.utf8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };
  ####
  services.logind.lidSwitch = "lock";
  services.logind.extraConfig = ''
    KillUserProcesses=no'';
  services.cron.enable = true;
  #### Nixpkgs
  nixpkgs.config.allowUnfree = false;
  
  ##### Nix source and build config
  nix = {
    allowedUsers = [ "@nix-users" ];
    # Nix is currently aggravating about not accepting empty values here: https://github.com/NixOS/nix/blob/master/scripts/download-from-binary-cache.pl.in#L240
    # Give it one that allows it to fail-fast, instead.
    binaryCaches = ["file:///var/local/nix/cache"];
    trustedBinaryCaches = [];
    buildCores = 0;
    requireSignedBinaryCaches = true;
    daemonIONiceLevel = 2;
    daemonNiceLevel = 2;
    extraOptions = ''
keep-env-derivations = true
substitute = false
build-use-substitutes = false
trusted-public-keys = foo:uX203jWszivwkcB7Ig0EjJKnu38oIgbNw01e1M4GGtI=
substituters = file:///var/local/nix/cache
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
  networking.firewall.allowPing = true;
  networking.firewall.rejectPackets = true;

  # Prevent dangerous distri hosts from being contacted.
  networking.extraHosts = "127.255.0.1 cache.nixos.org";

  #### Per-program config
  programs.ssh.startAgent = false;
  programs.ssh.knownHosts = ssh_pub.knownHosts;

  ######## X-windows things
  fonts.fontconfig.defaultFonts.serif = [ "DejaVu Sans" ];
}
