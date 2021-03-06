{pkgs, system, callPackage, ...}:
with pkgs; (callPackage ../base.nix {
  name = "mc0";
  LDEPS = with pkgs.xorg; [libX11 libXext libXcursor libXrandr libXxf86vm libGL_driver openal libpulseaudio libvorbis];
  BDEPS = [openjdk];
  JDEPS = [commonsIo commonsCompress];
})
