{config, pkgs, ...}: rec {
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };

  imports = [
    ./emacs
  ];

  environment.shellAliases = {
    grep = "grep --color=auto";
    ls = "ls --color=auto --time-style=long-iso";

    ne = "PAGER=cat nix-env";
    ns = "PAGER=cat nix-store";

    mp2mca = "mplayer2 -af resample=48000:1:2,hrtf -channels 6";
    ga = "git-annex";
  };

  programs.zsh.shellAliases = environment.shellAliases // {
    h = "fc -l -i 0";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # We don't need this.
    grub2 = pkgs.grub2.override { zfsSupport = false; };
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { x11Support = false; };

    # Put procps below coreutils for uptime(1).
    procps = pkgs.lib.hiPrio pkgs.procps;
  };
}
