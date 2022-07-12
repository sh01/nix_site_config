{ggame, is32, stdenv, writeText}: let
  b = if is32 then {
    bitS = "32";
    glSuff = "-32";
    nSuff = "32";
  } else {
    bitS = "64";
    glSuff = "";
    nSuff = "";
  };
  rg = writeText "rg" ''
#!/bin/sh
export LD_LIBRARY_PATH=${ggame}/local/ggame/${b.bitS}/lib:/run/opengl-driver${b.glSuff}/lib
exec "$@"
'';
in stdenv.mkDerivation {
  name = "SH_dep_" + b.bitS;
  builder = writeText "builder.sh" "
source $stdenv/setup
mkdir -p $out/bin
substitute ${rg} $out/bin/rg${b.nSuff}
chmod a+x $out/bin/rg*
";
}
