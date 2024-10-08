# To use this file directly, copy it to /etc/nixos/flake.nix.
#
# Afterwards, use for system build like:
# $ rm -f /etc/nixos/flake.lock; nixos-rebuild dry-activate --impure
# $ nix build '/etc/nixos#nixosConfigurations.'"$(hostname)"'.config.system.build.toplevel' --quiet --impure --print-out-paths --no-link --no-write-lock-file

{
  inputs.site_hosts = {
    type = "path";
    path = "/etc/site";
    flake = false;
  };
  outputs = {self, nixpkgs, ...}@inputs: let
    hm = import "${inputs.site_hosts}/nix/host";
  in (hm.outputs {inherit self nixpkgs;});
}
