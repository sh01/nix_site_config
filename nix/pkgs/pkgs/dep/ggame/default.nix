# Generic game environment.
{pkgs, system, callPackage, name, LINKNAME, is32, ...}:
let
  ignoreVulns = x: x // { meta.knownVulnerabilities = []; };
in with pkgs; (callPackage ../base.nix {
  inherit name LINKNAME;
  BDEPS = if is32 then [] else [openjdk21];
  JDEPS = [commonsIo commonsCompress];
  LDEPS = (import ./dep_libs.nix {inherit pkgs;});
})
