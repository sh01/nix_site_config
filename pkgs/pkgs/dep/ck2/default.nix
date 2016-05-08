{arch32, ...}:
with arch32.pkgs; (callPackage ../base.nix {
  name = "CK2";
  LDEPS = with xorg; [
    zlib tbb stdenv.cc.cc
    # Graphics stuff
    libX11 libXext libSM libICE mesa_glu mesa_noglu
    # Audio stuff. CK2 supports pulseaudio output directly.
    libpulseaudio 
  ];
})
