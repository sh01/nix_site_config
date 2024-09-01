{
  outputs = {self, nixpkgs, ...}: {
    nixosConfigurations = let
      inherit (nixpkgs) lib;
      h = x: nixpkgs.lib.nixosSystem {
        modules = [ x {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        }];
      };
    in {
      "keiko" = h ./keiko;
      "ika" = h ./ika;
      "bw0" = h ./bw0/config_bw2.nix;
      
      "liel" = h ./liel;
      
      "jibril" = h ./jibril;
      "yalda" = h ./yalda;
    };
  };
}
