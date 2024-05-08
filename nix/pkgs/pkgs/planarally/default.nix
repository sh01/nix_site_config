{ pkgs, fetchurl, ...}:

pkgs.stdenv.mkDerivation rec {
  pname = "planarally";
  version = "2023.3.0";

  src = fetchurl {
    url = "https://github.com/Kruptein/PlanarAlly/releases/download/${version}/planarally-bin-${version}.tar.gz";
    hash = "sha256-5zPnEQnmoqOmS+GYF1rXbjPITcnosrDXCOIdFgTQO0s=";
  };
  
  python3 = [
    (pkgs.python3.withPackages(ps: with ps; [
      aiohttp
      peewee
      pydantic
    ]))
  ];
  buildPhase = ''
    ls -la
    mkdir -p "$out"/pa/static/assets
    mkdir -p "$out"/pa/static/temp
    cp -a . "$out"/pa/
    ln -s "$python3/bin/python3" "$out"/
'';
}
