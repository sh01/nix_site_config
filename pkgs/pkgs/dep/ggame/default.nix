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
    # SDL2
    SDL2 SDL2_mixer SDL2_image SDL2_gfx SDL2_net SDL2_ttf
    # Graphics stuff.
    libX11 libXcursor libXinerama libXrandr libXi mesa mesa_glu libXxf86vm libXi libXext libXaw libXmu atk libXft libXt libXrender gdk_pixbuf cairo fontconfig.lib freeglut libSM libICE
    ## toolkits
    gnome.gtk pango.out glib
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis
    # Networking
    nss nspr
    # File formats
    bzip2.out zziplib
    # misc
    utillinux.out
  ];
})
