{ pkgs, sysPkgs, rks, uks }:
let
  vars = import ../base/vars.nix;
  slib = import ../lib;
  dns = (import ../base/dns.nix) {};
in {
  imports = [
    ../base
    ../base/site_stellvia.nix
  ];

  boot.isContainer = true;
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
    nameservers = [ "10.231.1.1" ];
    search = dns.conf.search;
  };
  
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
    extraConfig = "AcceptEnv DISPLAY";
  };

  environment.systemPackages = with pkgs; [(pkgs.callPackage ../pkgs/pkgs/scripts {}) firefox chromium] ++ sysPkgs;
}
