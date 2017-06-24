{
  nixpkgs.config.packageOverrides = pkgs:
  let od = pkgs.stdenv.lib.overrideDerivation;
  in rec {
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { guiSupport = false; };
    emacs = pkgs.emacs.override { withX = false; withGTK2 = false; withGTK3 = false; };
    "emacs-24.5" = pkgs."emacs-24.5".override { withX = false; withGTK2 = false; withGTK3 = false; };
    emacsWithPackages = (pkgs.emacsPackagesNgGen emacs).emacsWithPackages;
  };

  fonts.fontconfig.enable = false;
  environment.noXlibs = true;
}
