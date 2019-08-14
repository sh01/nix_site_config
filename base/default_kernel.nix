{pkgs, callPackage, buildPackages, ncurses, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, structuredExtraConfig ? {}, ...}: let
  vars = import vars.nix;
in buildLinux rec {
  version = "4.19.66";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "0r6vzarmi77fhivd1n6f667sgcw8zd54ykmhmp6rd52bbkhsp0f9";
  };

  inherit buildPackages callPackage ncurses stdenv perl buildLinux hostPlatform structuredExtraConfig;
  #kernelPatches = vars.kernelPatches;
  kernelPatches = [ pkgs.kernelPatches.modinst_arg_list_too_long ];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = false;
  features.netfilterRPFilter = true;
}
