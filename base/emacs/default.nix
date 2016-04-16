{pkgs, ...}:

let
  emacsConf = pkgs.stdenv.mkDerivation {
    cu = pkgs.coreutils;

    builder = builtins.toFile "builder.sh" ''
      PATH=$PATH:$cu/bin/
      P=$out/share/emacs/site-lisp/

      rd = pkgs.emacsPackages.rainbow-delimiters
      mkdir -p $P
      cp $FN $P/default.el
      ln -s $rd/share/emacs/site-lisp/elpa/rainbow-delimiters-*/rainbow-delimiters.el $P
    '';
    name = "emacs-config";
    FN = ./default.el;
}; in {
  environment.systemPackages = with pkgs; [
    (emacsWithPackages (epkgs: [ epkgs.rainbow-delimiters ]))
    emacsConf
  ];
}
