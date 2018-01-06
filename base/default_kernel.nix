{fetchurl, stdenv, perl, buildLinux, config, ...}: let
  vars = import vars.nix;
in (import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (rec {
  version = "4.14.12";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "1bsn73h3ilf7msyiqm5ny2zdj30b9r7k9sc8i03w3iggh3agf236";
  };

  inherit stdenv perl buildLinux;
  #kernelPatches = vars.kernelPatches;
  kernelPatches = [];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.netfilterRPFilter = true;
}))
