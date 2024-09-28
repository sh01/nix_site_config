{ pkgs, sysPkgs, lib, upAddr, vAddr, l, ... }:
let
  inherit (lib) mkForce;
  vars = pkgs.callPackage ../base/vars.nix {};
  slib = (pkgs.callPackage ../lib {});
  ssh_pub = (import ../base/ssh_pub.nix);
in {
  imports = [
    l.defaultConf
    l.siteConf
    ../base/nox.nix
    ./containers_common.nix
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
'';
    defaultGateway.address = ''${vAddr}'';
	};

  services = {
    openssh.enable = lib.mkForce false;
  };

  environment.systemPackages = with (import ../pkgs {}); sysPkgs;
}
