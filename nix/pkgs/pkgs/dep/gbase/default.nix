# Generic base environment.
{pkgs, stdenv, ...}:
with pkgs; stdenv.mkDerivation {
  name = "SH_dep_gbase";
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/local/ld; cd $out/local/ld
    ln -s ${glibc}/lib/ld-linux*so* 64
    ln -s ${arch32.glibc}/lib/ld-linux*so* 32
  '';
}
