{pkgs, ...}:

let
  emacsConf = epkgs: pkgs.stdenv.mkDerivation {
    cu = pkgs.coreutils;
    rd = epkgs.rainbow-delimiters;
    nm = epkgs.nix-mode;

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
    ((emacsPackagesFor emacs-nox).withPackages (epkgs: with epkgs; [ rainbow-delimiters nix-mode org (emacsConf epkgs) ]))
  ];
}
