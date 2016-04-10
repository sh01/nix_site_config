let
  pkgs = import <nixpkgs> {};
  epkgs =  pkgs."emacs24Packages";
  emacsConf = pkgs.stdenv.mkDerivation {
    cu = pkgs.coreutils;

    builder = builtins.toFile "builder.sh" ''
      PATH=$PATH:$cu/bin/
      P=$out/share/emacs/site-lisp/

      mkdir -p $P
      cp $FN $P/default.el
    '';
    name = "emacs-config";
    FN = ./default.el;
}; in {
  environment.systemPackages = with pkgs; [
    (emacsWithPackages [ epkgs.rainbowDelimiters ])
    emacsConf
  ];
}
