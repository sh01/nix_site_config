{config, ...}:
let
  nixVer = "24.05";
  npkg = name: {
    "${name}" = {
      exact = false;
      to = { type = "git"; url = "file:/root/git/nixpkgs?ref=l${nixVer}";};
    };
  };
in {
  # Make sure we don't accidentally retrieve to-be-executed code through insufficiently authenticated channels
  system.defaultChannel = "file:///var/local/nix/c0";
  nix = {
    channel.enable = false;
    registry = (npkg "nixpkgs") // (npkg "local_nixpkgs");
    nixPath = [
      "nixpkgs=flake:local_nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };
}
