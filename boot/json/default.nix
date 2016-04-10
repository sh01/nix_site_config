let
  pkgs = import <nixpkgs> {};
in {
  install = pkgs.substituteAll {
    src = ./builder.py;
    isExecutable = true;
    python3 = [pkgs.python3];
    out_filename = "/boot/nix.json";
  };
}
