{
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };
  environment.shellAliases = {
    ne = "PAGER=cat nix-env";
  };

  nixpkgs.config.packageOverrides = pkgs: {
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
