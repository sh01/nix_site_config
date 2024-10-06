{ pkgs, fetchurl, ...}: let
  ppkgs = (pkgs.callPackage ../.. {});
in pkgs.stdenv.mkDerivation rec {
  pname = "planarally";
  version = "2024.2";

  src = fetchurl {
    url = "https://github.com/Kruptein/PlanarAlly/releases/download/${version}/planarally-bin-${version}.tar.gz";
    hash = "sha256-dI0VVhG35SFiKv+ADPZELGut+3xAXx+uU83pMeRdaks=";
  };

  pPython = (pkgs.python3.withPackages(ps: with ps; [
    aiohttp
    aiohttp-session
    ppkgs.aiohttp-security
    peewee
    pydantic
    bcrypt
    python-socketio
  ]));

  wName = "run_planarally.py";
  runPA = ./run_planarally.py;
  installPhase = ''
    mkdir -p "$out/pa/static/mods"
    cp -r "./" "$out/pa"

    cp "$runPA" "$out"/pa/

    mkdir "$out/bin"
    wp="$out/bin/${wName}"
    substitute "${runPA}" "$wp" --replace-fail "@@python3@@" "${pPython}/bin/python3"
    chmod a+x "$wp"
'';
}
