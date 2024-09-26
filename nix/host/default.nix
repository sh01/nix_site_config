# Usage:
# $ nix build -I _hosts=/etc/site/nix/host --impure --expr '(import <_hosts>).liel'

let
  econfig = hostc: import (<nixpkgs> + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [(import hostc)];
  };
  h = hostc: (econfig hostc).config.system.build.toplevel;
in {
  "keiko" = h ./keiko;
  "ika" = h ./ika;
  "bw0" = h ./bw0/config_bw2.nix;
  
  "liel" = h ./liel;

  "uiharu" = h ./uiharu;
  
  "jibril" = h ./jibril;
  "yalda" = h ./yalda;
}
