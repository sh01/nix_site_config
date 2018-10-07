# Generic base environment.
{pkgs, stdenv, ...}:
with pkgs; stdenv.mkDerivation {
  name = "SH_dep_gbase";
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/share/gbase; cd $out/share/gbase
    mkdir ggame
    ln -s ${SH_dep_ggame}/share/lapps/ggame/ ggame/64
    ln -s ${SH_dep_ggame32}/share/lapps/ggame32/ ggame/32
    mkdir ld
    ln -s ${glibc}/lib/ld-linux*so* ld/64
    ln -s ${arch32.glibc}/lib/ld-linux*so* ld/32
  '';
}
