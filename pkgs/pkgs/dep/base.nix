{pkgs, system, name, LDEPS, BDEPS ? [], JDEPS ? [], ...}:
with pkgs; derivation {
  name = "SH_dep_" + name;
  inherit system coreutils findutils LDEPS BDEPS JDEPS;
  LINKNAME = name;
  PATH = ["${pkgs.bash}/bin"];
  LINK_DEPS = ./link_deps;
  glibc32 = pkgs.arch32.glibc;
  glibc64 = pkgs.glibc;
  builder = ./link_pre.sh;
  src = /var/empty;
}
