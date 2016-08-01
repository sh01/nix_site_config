{pkgs, system, callPackage, ...}:
with pkgs; (callPackage ../base.nix {
  name = "starbound";
  LDEPS = with pkgs.xorg; [
    # Graphics stuff
    mesa_glu mesa_noglu
    # SDL
    SDL2 SDL2_mixer SDL2_image SDL2_ttf SDL2_gfx
  ];
})
