{mkForce, overrideDerivation, ...}: {
  nixpkgs.config.packageOverrides = pkgs: rec {
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { guiSupport = false; };
    emacs = pkgs.emacs.override { withX = false; withGTK2 = false; withGTK3 = false; };
    "emacs-24.5" = pkgs."emacs-24.5".override { withX = false; withGTK2 = false; withGTK3 = false; };
    emacsWithPackages = (pkgs.emacsPackagesNgGen emacs).emacsWithPackages;
    libX11 = mkForce null;
    qemu = pkgs.qemu.override {
      gtkSupport = false;
      sdlSupport = false;
      pulseSupport = false;
      seccompSupport = false;
      smartcardSupport = false;
      spiceSupport = false;
    };
    #ruby = pkgs.ruby.override {
    #  defaultGemConfig = pkgs.defaultGemConfig // {
    #    cairo = _: null;
    #  };
    #};
    cairo = pkgs.cairo.override { x11Support = false; gobjectSupport = false; libGLSupported = false; glSupport = false; libGL = false; pdfSupport = false; };
  };

  fonts.fontconfig.enable = false;
  environment.noXlibs = true;
}
