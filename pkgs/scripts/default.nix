let
  pkgs = import <nixpkgs> {};
in
pkgs.srcOnly {
  name = "SH_scripts";
  src = ./s;
}
