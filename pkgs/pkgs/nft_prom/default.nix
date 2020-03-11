{ pkgs, python3Packages, ...}:
let
  python = pkgs.python3;
  pypkgs = python3Packages;
  nft = (pkgs.callPackage ../nftables-0.9.2/default.nix {});
in pypkgs.buildPythonPackage rec {
  pname = "nft_prom";
  version = "0";
  propagatedBuildInputs = [pypkgs.aiohttp nft];
  src = ./py;
}
