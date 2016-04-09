{
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };
  environment.shellAliases = {
    # Some nix-env builds (as for ghc-7.8.4) can fail in interesting ways when it's invoked with with non-C LANG.
    ne = "env PAGER=cat LANG=C nix-env";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # We don't need this.
    grub2 = pkgs.grub2.override { zfsSupport = false; };

    # Put procps below coreutils for uptime(1).
    # "outPath" entries are a hack around "cannot coerce a set to a string" bug (see https://github.com/NixOS/nixpkgs/issues/7425 )
    procps = pkgs.procps.overrideDerivation (a: {
      meta = {priority = 1; outPath="X";};
    });
    coreutils = pkgs.coreutils.overrideDerivation (a: {
      meta = {priority = 2; outPath="X";};
    });
  };
}
