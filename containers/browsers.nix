rks: uks: { config, pkgs, lib, ... }:

let
  vars = import ../base/vars.nix;
  slib = import ../lib;
in {
  imports = [
    ../base
    ../base/site_stellvia.nix
  ];

  boot.isContainer = true;
  ### User / Group config
  users = (slib.mkUserGroups (with vars.userSpecs; default ++ [ (sh_cbrowser uks) ])) // {
    users.root.openssh.authorizedKeys.keys = rks;
  };

  services.sshd = {
    enable = true;
    permitRootLogin = "without-password";
  };

  environment.systemPackages = with pkgs; [firefox chromium];
}
