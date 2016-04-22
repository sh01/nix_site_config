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
  users = let
    us = with vars.userSpecs { keys = { sh_cbrowser = uks;};}; default ++ [ sh_cbrowser ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
  };

  services.sshd = {
    enable = true;
    permitRootLogin = "without-password";
  };

  environment.systemPackages = with pkgs; [firefox chromium];
}
