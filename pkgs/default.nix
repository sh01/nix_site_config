{ system ? builtins.currentSystem }:

let
  pkgs_base = import <nixpkgs> { inherit system; };
  pkgs = pkgs_base // self;
  callPackage = pkgs.lib.callPackageWith(pkgs);
  self = rec {
    inherit callPackage pkgs;
    arch32 = (import ./default.nix { system = "i686-linux";});

    start_nix = callPackage ./pkgs/start_nix {};
    SH_blk_chk = callPackage ./pkgs/blk_chk {};
    SH_scripts = callPackage ./pkgs/scripts {};
    SH_sys_scripts = callPackage ./pkgs/sys_scripts {};
    SH_udev_containers = callPackage ./pkgs/udev_containers {};

    SH_dep_mc0 = callPackage ./pkgs/dep/mc0 {};
    SH_dep_factorio = callPackage ./pkgs/dep/factorio {};
    SH_dep_KSP = callPackage ./pkgs/dep/ksp {};
    SH_dep_CK2 = callPackage ./pkgs/dep/ck2 {};
    SH_dep_WL2 = callPackage ./pkgs/dep/wl2 {};
    SH_dep_Stellaris = callPackage ./pkgs/dep/stellaris {};
    SH_dep_starbound = callPackage ./pkgs/dep/starbound {};
    SH_dep_ggame = callPackage ./pkgs/dep/ggame {name = "ggame";};
    SH_dep_ggame32 = callPackage ./pkgs/dep/ggame {pkgs = arch32.pkgs; name = "ggame32";};
  };
in pkgs
