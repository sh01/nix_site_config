# Usage:
# $ nix build -I _hosts=/etc/site/nix/host --impure --expr '(import <_hosts>).liel'

let
  sysConf = hostc: {lib, config, pkgs, ...}:
    let
      callWith = autoargs: fn: args:
        let
          f = if lib.isFunction fn then fn else import fn;
        in (f (autoargs // args));

      lwCall = (callWith autoArgs);
      autoArgs = {
        inherit lib config pkgs;
        inherit lwCall;
        llib = lwCall ../lib {};
        lvars = lwCall ../base/vars.nix {};
      };
    in (lwCall hostc {});
  
  h = hostc:
    (import <nixpkgs/nixos> {
      configuration = sysConf hostc;
    }).system;
in {
  "keiko" = h ./keiko;
  "ika" = h ./ika;
  "bw0" = h ./bw0/config_bw2.nix;
  
  "liel" = h ./liel;

  "uiharu" = h ./uiharu;
  
  "jibril" = h ./jibril;
  "yalda" = h ./yalda;
}
