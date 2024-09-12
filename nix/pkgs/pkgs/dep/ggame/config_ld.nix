# Set 32/64bit nix-ld binaries and paths for using ggame dirs.
{pkgs, ...}: let
  pkgs32 = (import <nixpkgs> { system="i686-linux"; });
  ld = pkgs: let
    ldp = pkgs."nix-ld";
  in "${pkgs.nix-ld}/libexec/nix-ld";
  bpath = "/local/ggame";
  lpath = bits: "/run/current-system/sw/${bpath}/${toString bits}/lib";
  lpath64 = (lpath 64);
  lpath32 = (lpath 32);
  linkerpack = pkgs: bits: let
    sp = (ldsp bits);
  in pkgs.buildEnv {
    name = "linkerpack_${toString bits}";
    paths = [];
    postBuild = ''
      P="$out${sp}/"
      mkdir -p "$P"
      ln -s ${pkgs.stdenv.cc.bintools.dynamicLinker} "$P/ld.so"
    '';
    pathsToLink = [sp];
  };
  ldsp = bits: "/local/ggame/${toString bits}/ld";
  ldpref = bits: "/run/current-system/sw${ldsp bits}/ld.so";
  sys64 = "x86_64_linux";
  sys32 = "i686_linux";
in {
  environment = {
    ldso = (ld pkgs);
    ldso32 = (ld pkgs);
    
    pathsToLink = [bpath];
    variables = {
      "NIX_LD_LIBRARY_PATH" = "${lpath64}:${lpath32}";
      "NIX_LD_LIBRARY_PATH_${sys64}" = lpath64;
      "NIX_LD_LIBRARY_PATH_${sys32}" = lpath32;
      # From nixos/modules/programs/nix-ld.nix
      
      # We seem to need a newer version of nix-ld than 24.05 to properly map underscores?
      # Set it as sys default for now...
      "NIX_LD" = (ldpref 64);
      "NIX_LD_${sys64}" = (ldpref 64);
      "NIX_LD_${sys32}" = (ldpref 32);
    };
    systemPackages = [(linkerpack pkgs 64) (linkerpack pkgs32 32)];
  };
}
