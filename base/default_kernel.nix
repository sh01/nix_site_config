{pkgs, callPackage, buildPackages, ncurses, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, ...}: let
  vars = import vars.nix;
in (import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (rec {
  version = "4.14.71";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "12blj3zzvzs2nz8rp1g5ykibfvm355442c31l4ijr4mxphylg93n";
  };

  inherit buildPackages callPackage ncurses stdenv perl buildLinux hostPlatform;
  #kernelPatches = vars.kernelPatches;
  kernelPatches = [ pkgs.kernelPatches.modinst_arg_list_too_long ];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = false;
  features.netfilterRPFilter = true;
}))
