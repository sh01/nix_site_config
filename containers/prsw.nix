rks: uks: { config, pkgs, lib, ... }:

let
  vars = import ../base/vars.nix;
  slib = import ../lib;
  lpkgs = (import ../pkgs {});
in {
  imports = [
    ../base
    ../base/site_stellvia.nix
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  boot.isContainer = true;
  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh_prsw = uks; sh_prsw_net = uks;};}; default ++ [ sh_prsw sh_prsw_net sh_x ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
  };

  networking = {
    #nameservers = [ "10.16.0.1" ];
    #search = [ "sh.s ulwifi.s baughn-sh.s" ];
  };
  
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
    extraConfig = "AcceptEnv DISPLAY";
  };

  environment.systemPackages = with pkgs; [
    lpkgs.SH_scripts
  ];
}
