{config, ...}:
let
  nixVer = "24.05";
in {
   # Make sure we don't accidentally retrieve to-be-executed code through insufficiently authenticated channels
  config.system.defaultChannel = "file:///var/local/nix/c0";
  config.nix.registry = {
    "nixpkgs" = {
      exact = false;
      from = { id = "nixpkgs"; type = "indirect";};
      to = { type = "git"; url = "file:/root/git/nixpkgs?ref=l${nixVer}";};
    };
  };
}

