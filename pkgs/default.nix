{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };
  callPackage = pkgs.lib.callPackageWith ( pkgs // pkgs.xlibs // self);
  self = {
    start_nix = callPackage ./pkgs/start_nix {};
    SH_scripts = callPackage ./pkgs/scripts {};
  };
in self
