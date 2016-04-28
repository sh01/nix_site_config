let
  pkgs = import <nixpkgs> {};
in
pkgs.srcOnly {
  name = "SH_kde_conf";
  src = ./c;
} // {
  meta = {
    priority = "-9";
  };
}
