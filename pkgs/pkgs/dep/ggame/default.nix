# Generic game environment.
{pkgs, system, callPackage, name, ...}:
with pkgs; (callPackage ../base.nix {
  inherit name;
  BDEPS = [openjdk];
  JDEPS = [commonsIo commonsCompress];
  LDEPS = with pkgs.xorg; [
    # base libs.
    glibc stdenv.cc.cc.lib curl.out glew.out glew110.out libpng zlib freetype eject bzip2
    # Device access
    systemd.lib # udevlib's location now, for some reason.
    libpciaccess
    # OS stuff
    libcap
    # Weird services
    systemd dbus.lib
    # SDL1
    SDL SDL_sound SDL_mixer SDL_image SDL_gfx SDL_net SDL_ttf
    # SDL2
    SDL2 SDL2_mixer SDL2_image SDL2_gfx SDL2_net SDL2_ttf
    # Graphics stuff.
    libX11 libXcomposite libXcursor libXinerama libXrandr libXdamage libXfixes libXau libXdmcp libXi libXScrnSaver libXtst mesa mesa_glu libXxf86vm libXi libXext libXaw libXmu atk libXft libXt libXrender gdk_pixbuf cairo fontconfig.lib freeglut libSM libICE libtxc_dxtn libdrm
    libxkbcommon libxcb libxshmfence
    # Wayland graphics stuff (why).
    wayland
    # Video playback
    smpeg
    ## toolkits
    gnome3.gtk gnome3.gconf pango.out glib gtk2-x11
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis libogg libsndfile.out flac.out libmad fluidsynth
    # Networking
    nss nspr
    # File parsing
    bzip2.out zziplib xz expat lz4
    libjpeg.out libjpeg_original.out libtiff.out libwebp libmodplug
    # Printers ... why?
    cups
    # misc
    utillinux.out libgcrypt libgpgerror
  ];
})
