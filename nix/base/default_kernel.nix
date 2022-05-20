{pkgs, callPackage, buildPackages, ncurses, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, structuredExtraConfig ? {}, cpio, ...}: let
  vars = import vars.nix;
in (buildLinux rec {
  version = "5.15.32";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "1463cdfa223088610dd65d3eadeffa44ec49746091b8ae8ddac6f3070d17df86";
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
  # nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [cpio];
})
