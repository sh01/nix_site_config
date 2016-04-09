{
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };
  environment.shellAliases = {
    # Some nix-env builds (as for ghc-7.8.4) can fail in interesting ways when it's invoked with with non-C LANG.
    ne = "env PAGER=cat LANG=C nix-env";
    ns = "PAGER=cat nix-store";
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
