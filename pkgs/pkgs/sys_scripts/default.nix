# A collection of scripts for use by system programs.
# Putting them into a package allows us to cleanly refer to dependencies by path
# substitution.

{ pkgs, stdenv, ...}:
stdenv.mkDerivation {
  name = "sys_scripts";
  src = ./c;
  python2 = pkgs.python;
  bash = pkgs.bash;
  iproute = pkgs.iproute;
  patchPhase = ''
    substituteAllInPlace bin/ifup.py
    substituteAllInPlace bin/sh_ovpn_setup_iface.sh
  '';
  installPhase = "mkdir $out; cp -r bin $out";
}
