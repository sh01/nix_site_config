{
  nixpkgs.config.packageOverrides = pkgs: {
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { x11Support = false; };
    emacs = pkgs.emacs.override { withX = false; withGTK2 = false; withGTK3 = false; };
    "emacs-24.5" = pkgs."emacs-24.5".override { withX = false; withGTK2 = false; withGTK3 = false; };
  };

  environment.noXlibs = true;
}
