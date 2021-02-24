{pkgs, stdenv, fetchurl, libarchive, hostPlatform, ...}: stdenv.lib.overrideDerivation pkgs.microcodeIntel (a: rec {
  buildPhase = ''cat intel-ucode*/* > microcode.bin'';
})
