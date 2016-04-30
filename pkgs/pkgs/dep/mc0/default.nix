{pkgs, system, ...}:
with pkgs; derivation {
  name = "SH_dep_mc0";
  inherit system coreutils;
  LINKNAME = "mc0";
  LDEPS = with pkgs.xorg; [libX11 libXext libXcursor libXrandr libXxf86vm mesa openal];
  BDEPS = [openjdk];
  JDEPS = [commonsIo commonsCompress];
  builder = ../link_deps;
  src = /var/empty;
}
