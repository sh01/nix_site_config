{ pkgs, stdenv, ...}:

stdenv.mkDerivation {
  name = "deb_tools";
  src = ./c;
  python2 = [pkgs.python];
  patchPhase = ''
    substituteAllInPlace bin/ifup.py
  '';
  installPhase = "mkdir $out; cp -r bin $out";
}
