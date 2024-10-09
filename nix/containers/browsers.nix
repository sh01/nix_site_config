{ pkgs, sysPkgs, rks, uks, srvs, l, ...}:
let
  vars = (pkgs.callPackage ../base/vars.nix {});
  slib = (pkgs.callPackage ../lib {});
in {
  imports = with l.conf; [
    default
    site
    (l.call ./containers_common.nix)
  ];

  systemd.services = srvs;

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

  environment.etc."resolv.conf" = l.dns.resolvConfCont;
  networking = {
    search = l.dns.conf.search;
  };

  environment.systemPackages = with pkgs; [(pkgs.callPackage ../pkgs/pkgs/scripts {}) firefox chromium] ++ sysPkgs;
}
