# Generic game environment.
{pkgs, system, callPackage, name, LINKNAME, ...}:
let
  ignoreVulns = x: x // { meta.knownVulnerabilities = []; };
in with pkgs; (callPackage ../base.nix {
  inherit name LINKNAME;
  BDEPS = [openjdk17];
  JDEPS = [commonsIo commonsCompress];
  LDEPS = with pkgs.xorg; [
    # base libs.
    glibc libcxxabi stdenv.cc.cc.lib curl.out glew.out glew110.out libpng zlib freetype eject bzip2 xz.out gmp
    libpng12 # Portal 1
    # Device access
    libudev
    libpciaccess
    # OS stuff
    libcap
    lsb-release
    # Weird services
    systemd dbus.lib
    # SDL1
    SDL SDL_sound SDL_mixer SDL_image SDL_gfx SDL_net SDL_ttf
    # SDL2
    SDL2 SDL2_mixer SDL2_image SDL2_gfx SDL2_net SDL2_ttf
    # Graphics stuff.
    libX11 libXcomposite libXcursor libXinerama libXrandr libXdamage libXfixes libXau libXdmcp libXi libXScrnSaver libXtst libGL libGLU libXxf86vm libXi libXext libXaw libXmu atk libXft libXt libXrender gdk_pixbuf cairo fontconfig.lib freeglut libSM libICE libdrm
    libxkbcommon libxcb libxshmfence
    libXpm.out
    # Wayland graphics stuff (why).
    wayland
    # Video playback
    smpeg
    ## toolkits
    gnome3.gtk gnome2.GConf pango.out glib gtk2-x11
    python3Packages.pygame python3Packages.pygame_sdl2 python3Packages.pygame-gui
    glib.out
    icu
    # Audio stuff.
    alsaLib libpulseaudio openal alsaPlugins libvorbis libogg libsndfile.out flac.out libmad fluidsynth
    # Networking
    nss nspr
    # File parsing
    bzip2.out zziplib xz expat lz4
    libjpeg.out libjpeg_original.out libtiff.out libwebp libmodplug
    # DBs
    sqlite.out
    # Printers ... why?
    cups.lib
    # Crypto
    libgcrypt nettle openssl.out (openssl_1_0_2.overrideAttrs ignoreVulns).out libkrb5 openldap gnutls.out
    # misc
    util-linux.out util-linux.lib libgpgerror
    # Goldberg steam emu
    protobuf protobuf3_9
    utillinux.out libgpgerror at_spi2_atk at_spi2_core
  ];
})
