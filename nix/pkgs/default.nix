{ system ? builtins.currentSystem, pkgs ? null }:
#assert pkgs != null;
let
  pkgs_base = if pkgs != null then pkgs else (import <nixpkgs> { inherit system; });
  pkgs_ = pkgs_base // self;
  callPackage = pkgs_.lib.callPackageWith(pkgs_);
  self = rec {
    inherit callPackage;
    pkgs = pkgs_;
    arch32 = (import ./default.nix { system = "i686-linux";});

    start_nix = callPackage ./pkgs/start_nix {};

    nft_prom = callPackage ./pkgs/nft_prom {};
    planarally = callPackage ./pkgs/planarally {};
    aiohttp-security = callPackage ./pkgs/aiohttp-security {inherit (pkgs.python3Packages) aiohttp buildPythonPackage cryptography setuptools;};
    
    SH_blk_chk = callPackage ./pkgs/blk_chk {};
    SH_scripts = callPackage ./pkgs/scripts {};
    SH_sys_scripts = callPackage ./pkgs/sys_scripts {};
    SH_udev_containers = callPackage ./pkgs/udev_containers {};

    SH_dep_gbase = callPackage ./pkgs/dep/gbase {};
    SH_dep_ggame = callPackage ./pkgs/dep/ggame {name = "ggame"; LINKNAME = "ggame/64"; is32=false;};
    SH_dep_ggame_rg = callPackage ./pkgs/dep/ggame/rg.nix {ggame = SH_dep_ggame; is32 = false;};
    SH_dep_ggame32 = callPackage ./pkgs/dep/ggame {pkgs = arch32.pkgs; name = "ggame32"; LINKNAME = "ggame/32"; is32=true; };
    SH_dep_ggame32_rg = callPackage ./pkgs/dep/ggame/rg.nix {ggame = SH_dep_ggame32; is32 = true;};
    SH_dep_java8 = callPackage ./pkgs/dep/java8.nix {};
    SH_dep_java17 = callPackage ./pkgs/dep/java17.nix {};

    # old stuff
    SH_dep_mc0 = callPackage ./pkgs/dep/mc0 {};
    SH_dep_factorio = callPackage ./pkgs/dep/factorio {};
    SH_dep_CK2 = callPackage ./pkgs/dep/ck2 {};
    SH_dep_WL2 = callPackage ./pkgs/dep/wl2 {};
    SH_dep_Stellaris = callPackage ./pkgs/dep/stellaris {};
    SH_dep_starbound = callPackage ./pkgs/dep/starbound {};
  };
in pkgs_
