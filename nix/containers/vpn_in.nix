{ pkgs, sysPkgs, lib, upAddr, vAddr, l, ... }:
let
  inherit (lib) mkForce;
  vars = pkgs.callPackage ../base/vars.nix {};
  slib = (pkgs.callPackage ../lib {});
in {
  imports = with l.conf; [
    default
    site
    ../base/nox.nix
    (l.call ./containers_common.nix)
  ];

  environment.etc."resolv.conf".text = mkForce "nameserver 8.8.8.8\n";

  ### User / Group config
  users = let
    us = with vars.userSpecs {}; default;
  in {
    users = (slib.mkUsers us);
    groups = (slib.mkGroups us);
    inherit (slib.mkUserGroups {}) enforceIdUniqueness;
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };
  
  networking = {
    firewall.enable = false;
    localCommands = ''
      PATH=$PATH:${pkgs.iproute2}/bin
      ip route replace ${vAddr} dev eth0
      ip route replace default via ${vAddr} metric 0
      ip -6 route replace fd9d:1852:3555::/48 via fd00:ffff::1
'';
    defaultGateway.address = ''${vAddr}'';
    useDHCP = false;
  };

  services = {
    openssh.enable = lib.mkForce false;
  };

  environment.systemPackages = with (import ../pkgs {}); sysPkgs;
}
