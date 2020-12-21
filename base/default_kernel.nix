{pkgs, callPackage, buildPackages, ncurses, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, structuredExtraConfig ? {}, cpio, ...}: let
  vars = import vars.nix;
in (buildLinux rec {
  version = "5.4.82";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "1byx163v83aw0ixphwz20znml2s2n3cy1kp89vgwbdiqxbj5hi7v";
  };

  inherit buildPackages callPackage ncurses stdenv perl buildLinux hostPlatform structuredExtraConfig;
  #kernelPatches = vars.kernelPatches;
  #kernelPatches = [ pkgs.kernelPatches.modinst_arg_list_too_long ];
  kernelPatches = [];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = false;
  features.netfilterRPFilter = true;
}).overrideDerivation (oldAttrs: {
  # Monkey-patch compatibility for newer kernel versions
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [cpio];
})
