{pkgs, stdenv, fetchurl, libarchive, hostPlatform, ...}: stdenv.lib.overrideDerivation pkgs.microcodeIntel (a: rec {
  version = "20180807a";
  src = fetchurl {
    url = "https://downloadmirror.intel.com/28087/eng/microcode-${version}.tgz";
    sha256 = "0dw1akgzdqk95pwmc8gfdmv7kabw9pn4c67f076bcbn4krliias6";
  };
  buildPhase = ''cat intel-ucode*/* > microcode.bin'';
})
