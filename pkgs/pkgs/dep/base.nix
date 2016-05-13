{pkgs, system, name, LDEPS, BDEPS ? [], JDEPS ? [], ...}:
with pkgs; derivation {
  name = "SH_dep_" + name;
  inherit system coreutils findutils LDEPS BDEPS JDEPS;
  LINKNAME = name;
  SH = bash;
  glibc32 = pkgs.arch32.glibc;
  glibc64 = pkgs.glibc;
  builder = ./link_deps;
  src = /var/empty;
}
