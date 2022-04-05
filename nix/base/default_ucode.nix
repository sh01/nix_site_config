{pkgs, stdenv, fetchurl, libarchive, hostPlatform, ...}: pkgs.microcodeIntel.overrideDerivation (a: rec {
  buildPhase = ''cat intel-ucode*/* > microcode.bin'';
})
