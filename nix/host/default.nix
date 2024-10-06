# Usage:
# $ nix build -I _hosts=/etc/site/nix/host --impure --expr '(import <_hosts>).liel'

let
  inherit (builtins) listToAttrs;
  sysConf = hostname: {lib, config, pkgs, system, ...}@args:
    let
      hostc = ./. + ("/" + hostname);
    in
      (import ../lib/l.nix {inherit hostname hostc;} args).call hostc {};
  
  h = hostname:
    (import <nixpkgs/nixos> {
      configuration = sysConf hostname;
    });

  hostConfigP = hn: {
    name = hn;
    value = h hn;
  };
  hostNs = ["keiko" "bw0" "liel" "nova" "uiharu" "jibril" "yalda" "ika"];

in listToAttrs (map hostConfigP hostNs)
