{pkgs, system, callPackage, ...}:
with pkgs; (callPackage ../base.nix {
  name = "duskers";
  LDEPS = with pkgs.xorg; [
    # base libs.
    stdenv.cc.cc curl glew libpng zlib freetype eject bzip2
    # Graphics stuff.
    libX11 libXcursor libXinerama libXrandr libXi mesa libXxf86vm libXi
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis
  ];
})
