{system, lib, pkgs, ...}@args:
let
  hostname = builtins.getEnv "NIX_HOST";
  #host = (import ../host)."${hostname}";
  hostc = ../host + ("/" + hostname);
  conf = (import ./l.nix {inherit hostname hostc;} args).call hostc {};
in conf
