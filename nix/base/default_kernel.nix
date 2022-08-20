{pkgs, callPackage, buildPackages, ncurses, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, structuredExtraConfig ? {}, cpio, ...}: let
in (buildLinux rec {
  version = "5.18.12";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "40b74d0942f255da07481710e1083412d06e37e45b8f9d9e34ae856db37b9527";
  };

  inherit buildPackages callPackage ncurses stdenv perl buildLinux hostPlatform structuredExtraConfig;
  #kernelPatches = [ pkgs.kernelPatches.modinst_arg_list_too_long ];
  kernelPatches = [];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = false;
  features.netfilterRPFilter = true;
}).overrideDerivation (oldAttrs: {
  # Monkey-patch compatibility for newer kernel versions
  # nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [cpio];
})
