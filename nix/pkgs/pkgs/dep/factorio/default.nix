{pkgs, system, callPackage, ...}:
with pkgs; (callPackage ../base.nix {
  name = "factorio";
  LDEPS = with pkgs.xorg; [
    # Graphics stuff
    libX11 libXcursor libXinerama libXrandr libXi libGL_driver
    # Audio stuff. We need alsaPlugins for ALSA->pulse forwarding.
    alsaLib libpulseaudio alsaPlugins
  ];
})
