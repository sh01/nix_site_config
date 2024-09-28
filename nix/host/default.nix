# Usage:
# $ nix build -I _hosts=/etc/site/nix/host --impure --expr '(import <_hosts>).liel'

let
  inherit (builtins) listToAttrs;
  sysConf = hostname: {lib, config, pkgs, ...}@args:
    let
      hostc = ./. + ("/" + hostname);
    in
      (import ../lib/l.nix {inherit hostname hostc;} args).call hostc {};
  
  h = hostname:
    (import <nixpkgs/nixos> {
      configuration = sysConf hostname;
    }).system;

  hostConfigP = hn: {
    name = hn;
    value = h hn;
  };
  hostNs = ["keiko" "bw0" "liel" "uiharu" "jibril" "yalda"];

in listToAttrs (map hostConfigP hostNs)
