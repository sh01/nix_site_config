{arch32, ...}:
with arch32.pkgs; (callPackage ../base.nix {
  name = "WL2";
  LDEPS = with xorg; [
    zlib stdenv.cc.cc
    # Graphics stuff
    libX11 libXext libXcursor libXrandr libSM libICE libGL_driver
    # Audio stuff. WL2 outputs ALSA.
    alsaLib
  ];
})
