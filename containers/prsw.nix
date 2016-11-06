{ sysPkgs, rks, uks }:
let
  vars = import ../base/vars.nix;
  slib = import ../lib;
in {
  imports = [
    ../base
    ../base/site_stellvia.nix
    ../base/alsa2pulse.nix
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    s3tcSupport = true;
  };
  
  boot.isContainer = true;
  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh = uks; sh_prsw = uks; sh_prsw_net = uks;};}; default ++ [ sh_prsw sh_prsw_net sh_x ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
  };

  networking = {
    nameservers = [ "10.231.1.1" ];
  };
  
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
    extraConfig = "AcceptEnv DISPLAY";
  };

  environment.systemPackages = sysPkgs;
}
