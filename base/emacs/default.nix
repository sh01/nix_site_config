let
  pkgs = import <nixpkgs> {};
  emacsConf = pkgs.stdenv.mkDerivation {
    cu = pkgs.coreutils;
    rd = pkgs."emacs24Packages".rainbowDelimiters;

    builder = builtins.toFile "builder.sh" ''
      PATH=$PATH:$cu/bin/
      P=$out/share/emacs/site-lisp/

      mkdir -p $P
      cp $FN $P/default.el
      ln -s $rd/share/emacs/site-lisp/rainbow-delimiters.el $P/
    '';
    name = "emacs-config";
    FN = ./default.el;
}; in {
  environment.systemPackages = with pkgs; [
    emacs
    emacs24Packages.rainbowDelimiters
    emacsConf
  ];
}
