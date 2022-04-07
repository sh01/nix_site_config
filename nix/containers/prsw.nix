{ pkgs, sysPkgs, rks, uks, ... }:
let
  vars = import ../base/vars.nix;
  slib = (pkgs.callPackage ../lib {});
  dns = (import ../base/dns.nix) {};
in {
  imports = [
    ../base
    ../base/site_wl.nix
    ../base/alsa2pulse.nix
    ./containers_common.nix
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    #s3tcSupport = true;
  };
  
  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh = uks; sh_prsw = uks; sh_prsw_net = uks;};}; default ++ [ sh_prsw sh_prsw_net sh_x stash ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
  };

  networking = {
    firewall.enable = false;
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
  };

  environment.systemPackages = with (import ../pkgs {}); sysPkgs ++ [SH_dep_gbase];
}
