{pkgs, l, ...}: let
  inherit (pkgs) writeShellApplication;
  inherit (l.lib) subScript subInts;
  inherit (pkgs.xorg) xauth;

  fPatchXauth = subScript (subInts.py // {src=./patch_xauth.py;});
  fSetupAuth = subScript (subInts.bash // {
    src = ./setup_cont_auth.sh;
    xauth = "${pkgs.xorg.xauth}/bin/xauth";
    inherit fPatchXauth;
  });
  
in {
  inherit fSetupAuth;
}
