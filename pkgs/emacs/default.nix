{pkgs, ...}:

let
  emacsConf = epkgs: pkgs.stdenv.mkDerivation {
    cu = pkgs.coreutils;
    rd = epkgs.rainbow-delimiters;

    builder = builtins.toFile "builder.sh" ''
      PATH=$PATH:$cu/bin/
      P=$out/share/emacs/site-lisp/

      mkdir -p $P
      cp $FN $P/default.el
      ln -s $rd/share/emacs/site-lisp/elpa/rainbow-delimiters-*/rainbow-delimiters.el $P
    '';
    name = "emacs-config";
    FN = ./default.el;
}; in {
  emacsPackages = with pkgs; [
    (emacsWithPackages (epkgs: [ epkgs.rainbow-delimiters (emacsConf epkgs) ]))
  ];
}
