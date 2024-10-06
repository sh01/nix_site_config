{ lib, fetchurl, buildPythonPackage, fetchFromGitHub,
  # build-system
  setuptools,
  # dependencies
  aiohttp, cryptography}:

buildPythonPackage rec {
  pname = "aiohttp-security";
  version = "0.5.0";
  pyproject = true;

  src = fetchurl {
    url = "https://github.com/aio-libs/aiohttp-security/releases/download/v${version}/aiohttp-security-${version}.tar.gz";
    hash = "sha256-UMtyTTEOHQKJeYu5iuhSw7dbd+j1HOUVnFe3Jh0GOL0=";
  };

  build-system = [ setuptools ];
  dependencies = [ aiohttp cryptography ];

  doCheck = false;
  pythonImportsCheck = [ "aiohttp_security" ];
}
