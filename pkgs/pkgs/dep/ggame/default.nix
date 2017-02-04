# Generic game environment.

{pkgs, system, callPackage, name, ...}:
with pkgs; (callPackage ../base.nix {
  inherit name;
  LDEPS = with pkgs.xorg; [
    # base libs.
    stdenv.cc.cc.lib curl glew libpng zlib freetype eject bzip2
    # Device access. Used by e.g. Rimworld 1393.
    pkgs.udev182 # TODO: See if we can get a sane index..
    # SDL1
    SDL SDL_sound SDL_image SDL_gfx SDL_net SDL_ttf
    # Graphics stuff.
    libX11 libXcursor libXinerama libXrandr libXi mesa mesa_glu libXxf86vm libXi libXext
    libXmu atk
    ## UI toolkits
    gnome.gtk pango
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis
  ];
})
