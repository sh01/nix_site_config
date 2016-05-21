{arch32, ...}:
with arch32.pkgs; (callPackage ../base.nix {
  name = "Stellaris";
  LDEPS = with xorg; [
    stdenv.cc.cc libuuid
    # Graphics stuff
    libX11 libXxf86vm mesa_glu mesa_noglu
    # Audio stuff. Stellaris outputs ALSA.
    alsaLib
  ];
})
