# Generic base environment.
{pkgs, stdenv, ...}:
with pkgs; stdenv.mkDerivation {
  name = "SH_dep_java17";
  jdk = openjdk17;
  phases = ["installPhase"];
  installPhase = ''
    dst="$out/local"
    mkdir -p "$dst"
    ln -s "$jdk" "$dst/java17"
  '';
}
