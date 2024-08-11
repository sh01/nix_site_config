{ pkgs, sysPkgs, rks, uks, services}:
let
  vars = (pkgs.callPackage ../base/vars.nix {});
  slib = (pkgs.callPackage ../lib {});
  dns = (import ../base/dns.nix) {};
in {
  imports = [
    ../base
    ../base/site_wi.nix
    ./containers_common.nix
  ];

  systemd.services = services;

  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh = uks; sh_cbrowser = uks;};}; default ++ [ sh_x sh_cbrowser ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
    inherit (slib.mkUserGroups {}) enforceIdUniqueness;
  };

  environment.etc."resolv.conf" = dns.resolvConfCont;
  networking = {
    search = dns.conf.search;
  };

  environment.systemPackages = with pkgs; [(pkgs.callPackage ../pkgs/pkgs/scripts {}) firefox chromium] ++ sysPkgs;
}
