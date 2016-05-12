{pkgs, system, callPackage, ...}:
with pkgs; (callPackage ../base.nix {
  name = "KSP";
  LDEPS = with pkgs.xorg; [
    stdenv.cc.cc
    # Graphics stuff
    libX11 libXcursor libXrandr mesa libtxc_dxtn
    # Audio stuff. KSP supports output through pulseaudio directly.
    libpulseaudio
  ];
})
