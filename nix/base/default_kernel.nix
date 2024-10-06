{pkgs, structuredExtraConfig ? {}, ...}: let
  inherit (pkgs) callPackage buildPackages ncurses fetchurl stdenv perl buildLinux hostPlatform;
in (buildLinux rec {
  version = "6.1.60";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "58520e7ae5a6af254ddf7ddbfc42e4373b0d36c67d467f6e35a3bd1672f5fb0a";
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
