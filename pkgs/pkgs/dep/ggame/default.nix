# Generic game environment.

{pkgs, system, callPackage, name, ...}:
with pkgs; (callPackage ../base.nix {
  inherit name;
  LDEPS = with pkgs.xorg; [
    # base libs.
    stdenv.cc.cc curl glew libpng zlib freetype eject bzip2
    # SDL1
    SDL SDL_sound SDL_image SDL_gfx SDL_net SDL_ttf
    # Graphics stuff.
    libX11 libXcursor libXinerama libXrandr libXi mesa libXxf86vm libXi
    xorg.libXmu atk
    ## UI toolkits
    gnome.gtk pango
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis
  ];
})
