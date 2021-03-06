{ pkgs, sysPkgs, rks, uks }:
let
  vars = import ../base/vars.nix;
  slib = import ../lib;
  dns = (import ../base/dns.nix) {};
in {
  imports = [
    ../base
    ../base/site_wl.nix
    ./containers_common.nix
  ];

  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh = uks; sh_cbrowser = uks;};}; default ++ [ sh_x sh_cbrowser ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
  };

  environment.etc."resolv.conf" = dns.resolvConfCont;
  networking = {
    search = dns.conf.search;
  };

  environment.systemPackages = with pkgs; [(pkgs.callPackage ../pkgs/pkgs/scripts {}) firefox chromium] ++ sysPkgs;
}
