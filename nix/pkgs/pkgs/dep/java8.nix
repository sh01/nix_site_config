# Generic base environment.
{pkgs, stdenv, ...}:
with pkgs; stdenv.mkDerivation {
  name = "SH_dep_java8";
  openjdk8 = openjdk8;
  phases = ["installPhase"];
  installPhase = ''
    dst="$out/local"
    mkdir -p "$dst"
    ln -s "$openjdk8" "$dst/java8"
  '';
}
