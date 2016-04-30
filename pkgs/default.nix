{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };
  callPackage = pkgs.lib.callPackageWith ( pkgs // pkgs.xlibs // self);
  self = {
    start_nix = callPackage ./pkgs/start_nix {};
    SH_scripts = callPackage ./pkgs/scripts {};
    SH_udev_containers = callPackage ./pkgs/udev_containers {};

    SH_dep_mc0 = callPackage ./pkgs/dep/mc0 {};
  };
in self
