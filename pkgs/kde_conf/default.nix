let
  pkgs = import <nixpkgs> {};
in
pkgs.srcOnly {
  meta = {
    priority = "-9";
  };
  name = "SH_kde_conf";
  src = ./c;
}
