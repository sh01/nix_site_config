{ config, pkgs, lib, fetchFromGitHub, ... }:
let
  inherit (lib) overrideDerivation elemAt;
  inherit (pkgs) fetchFromGitHub fetchpatch;
  pyfix = {
    packageOverrides = python-self: python-super: {
      pyopenssl = python-super.pyopenssl.overridePythonAttrs (old: { doCheck = false;} );
    };
  };
in {
  nixpkgs.config.packageOverrides = up: {
    ninja = overrideDerivation up.ninja (super: rec {
      version = "1.10.0";
      src = fetchFromGitHub {
        owner = "ninja-build";
        repo = "ninja";
        rev = "v${version}";
        sha256 = "1fbzl7mrcrwp527sgkc1npfl3k6bbpydpiq98xcf1a1hkrx0z5x4";
      };
      patches = [];
    });
    expat = overrideDerivation up.expat (up:
      let
        p0 = (elemAt up.patches 0);
      in rec {
      #patches = [(fetchpatch {
      #  url = (elemAt p0.urls 0);
      #  sha256 = p0.outputHash;
      #  stripLen = 1;
      #})];
      patches = [];
    });

    # Fix flake test error by overriding running of borked test cases.
    # Pythons: Skip stupid flaky tests.
    python27 = up.python27.override pyfix;
    python37 = up.python37.override pyfix;

    # Need to override by version to catch build reference.
    perl530 = up.perl530.override {
      config = {
        perlPackageOverrides = _: {
          TimeDate = up.perl530.pkgs.TimeDate.overrideAttrs (_: {
            doCheck = false;
          });
        };
      };
    };
    libuv = up.libuv.overrideAttrs (_: {
      doCheck = false;
    });
    # Borked by unavailable patch for security issue.
    # libvorbis = null;
    # libtheora = null;

    # Non-crucial, but nice fixes.
    nix = up.nix.override { withAWS = false; };
  };
}
