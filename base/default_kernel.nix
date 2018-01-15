{pkgs, fetchurl, stdenv, perl, buildLinux, config, hostPlatform, ...}: let
  vars = import vars.nix;
in (import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (rec {
  version = "4.14.12";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "1bsn73h3ilf7msyiqm5ny2zdj30b9r7k9sc8i03w3iggh3agf236";
  };

  inherit stdenv perl buildLinux hostPlatform;
  #kernelPatches = vars.kernelPatches;
  kernelPatches = [ pkgs.kernelPatches.modinst_arg_list_too_long ];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = false;
  features.netfilterRPFilter = true;
}))
