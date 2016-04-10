let
  ssh_pub = import ./ssh_pub.nix;
in {
  userSpecs = [
    ["sh" 1000 ["wheel" "nix-users"] [ssh_pub.sh_allison]]
    ["backup-client" 2000 [] [ssh_pub.root_keiko]]
  ];
}
