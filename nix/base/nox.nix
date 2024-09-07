{mkForce, lib, ...}: {
  nixpkgs.config.packageOverrides = pkgs: rec {
    # Don't pull in a full gtk stack for this.
    gnupg = pkgs.gnupg.override { guiSupport = false; };
    emacs = pkgs.emacs.override { withX = false; withGTK2 = false; withGTK3 = false; };
    "emacs-24.5" = pkgs."emacs-24.5".override { withX = false; withGTK2 = false; withGTK3 = false; };
    emacsWithPackages = (pkgs.emacsPackagesFor emacs).emacsWithPackages;
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
    # Pulled in indirectly for documentation compilation by build environments.
    cairo = pkgs.cairo.override { x11Support = true; };
    # Borked.
    #pango = pkgs.pango.override { x11Support = false; };

    qt512 = pkgs.qt512.overrideScope' (_: up: {
      qtwebkit = (up.qtwebkit.overrideAttrs (_: {
        cmakeFlags = ["-DPORT=Qt" "-DENABLE_WEB_AUDIO=OFF" "-DENABLE_VIDEO=OFF" "-DENABLE_WEBGL=OFF" "-DENABLE_LEGACY_WEB_AUDIO=OFF" "-DENABLE_MEDIA_SOURCE=OFF"];
        # --no-web-audio --no-webgl
      })).override {
        gst_all_1 = {
          gstreamer = null;
          gst-plugins-base = null;
        };
      };
    });
    mesa = pkgs.mesa.override { vulkanDrivers = []; eglPlatforms = ["x11" "surfaceless"]; withValgrind = false; };
    gtk3 = pkgs.gtk3.override { x11Support = false; xineramaSupport = false; cupsSupport = false; };
    gst_all_1 = pkgs.gst_all_1 // (let up = pkgs.gst_all_1; in {
      #gst-plugins-base = up.gst-plugins-base.override { enableX11 = true; enableWayland = false; enableAlsa = false; enableCocoa = false; enableCdparanoia = false; };
      gst-plugins-base = null;
    });
    libsForQt512 = pkgs.libsForQt512 // (let up = pkgs.libsForQt512; in {
      qtbase = up.qtbase.override {libGLSupported = false; cups = null; mysql = null; postgresql = null; withGtk3 = false; dconf = null;};
    });
    libpulseaudio = null;
    #libtheora = null;
    #libvorbis = null;
  };

  fonts.fontconfig.enable = false;
  environment.noXlibs = true;
}
