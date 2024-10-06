# Ika is a small traffic-routing cloud deployment.
# Manual setup things:
#  /var/spool . go+rx (uptimed)
#  /var/local/run/openvpn openvpn:openvpn

{ config, lib, pkgs, l, ... }:
let
  inherit (pkgs) callPackage;
  inherit (lib) mkForce;
  nft = callPackage ../../base/nft.nix {};
in {
  imports = with l.conf; [
    <nixpkgs/nixos/modules/virtualisation/digital-ocean-config.nix>
    ../../base/img/digitalocean.nix
    default
    ../../base/nox.nix
  ] ++ (with l.srv; [
    prom_exp_node
    wireguard
  ]);
  
  boot.kernelPackages = pkgs.linuxPackagesFor (l.call ../../base/default_kernel.nix {});

  networking = {
    hostName = "ika";
    hostId = "84d5fcc9";
    firewall.enable = false;
    useNetworkd = true;
    resolvconf.enable = false;
  };
  
  systemd.network = {
   networks = {
      "global" = {
        matchConfig = { Name = "eth0"; };
        enable = true;
        address = ["24.199.109.57/20"];
        networkConfig = { Description = ".."; };
        routes = [{
          routeConfig.Gateway = "24.199.96.1";
        }];
        #dns = ["8.8.8.8"];
      };
   };
  };

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); with pkgs; [
    base
    cliStd
    uptimed
  ];

  system.includeBuildDependencies = false;

  # NFT NAT is generally fragile. Considerations:
  # * You do need sysctl options to enable packet routing in the first place. We set these below.
  # * NFT DNAT can be broken by iptable_nat code being loaded into the kernel, *and* the iptables 'nat' table being touched.
  #   * Just having the code by itself should be fine, so long as the table is never touched.
  #   * If it is touched, -F will not fix this, but 'rmmod iptable_nat' (if possible) will.
  #   * networking.firewall.enable=false above should make nixos leave it alone.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = mkForce true;
    "net.ipv4.conf.all.forwarding" = mkForce true;
    "net.ipv4.conf.default.forwarding" = mkForce true;
    "net.ipv6.conf.all.forwarding" = mkForce true;
  };
  
  environment.etc."nft.conf".text = l.call ./nft.nix {};
  systemd.services = nft.services;

  sound.enable = false;
  security.polkit.enable = false;

  # Services config
  services = {
    udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="4a:e2:44:d3:92:08", KERNEL=="eth*", NAME="eth0"
    '';
  
    openssh.enable = true;
    openssh.moduliFile = ./sshd_moduli;
    uptimed.enable = true;
  };

  users = lib.mkMerge [(l.lib.mkUserGroups (with l.vars.userSpecs {}; default)) {
    users.root.password = "login1";
  }];
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "24.05";
}
