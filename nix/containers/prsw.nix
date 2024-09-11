{ pkgs, sysPkgs, rks, uks, services, ... }:
let
  vars = (pkgs.callPackage ../base/vars.nix {});
  slib = (pkgs.callPackage ../lib {});
  dns = (import ../base/dns.nix) {};
  ssh_pub = (import ../base/ssh_pub.nix);
in {
  imports = [
    ../base
    ../base/site_wi.nix
    ../base/alsa2pulse.nix
    ./containers_common.nix
  ];

  systemd.services = services;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  ### User / Group config
  users = let
    us = with vars.userSpecs { keys = { sh = [ssh_pub.sh_allison]; sh_prsw = uks; sh_prsw_net = uks; sophia = [];};}; default ++ [ prsw prsw_net sh_x stash ];
  in {
    users = (slib.mkUsers us) // {
      root.openssh.authorizedKeys.keys = rks;
    };
    groups = (slib.mkGroups us);
    inherit (slib.mkUserGroups {}) enforceIdUniqueness;
  };

  networking = {
    firewall.enable = false;
    extraHosts = "127.0.0.1 sessionserver.mojang.com authserver.mojang.com api.mojang.com api.minecraftservices.com pc.realms.minecraft.net\n";
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
  };

  programs."nix-ld" = {
    enable = true;
    libraries = (import ../pkgs/pkgs/dep/ggame/dep_libs.nix {inherit pkgs;});
  };
  environment.systemPackages = with (import ../pkgs {}); sysPkgs ++ [SH_dep_gbase];
}
