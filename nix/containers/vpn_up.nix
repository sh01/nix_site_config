{ pkgs, sysPkgs, lib, upAddr, cAddr, l, ... }:
let
  inherit (lib) mkForce;
  vars = pkgs.callPackage ../base/vars.nix {};
  slib = (pkgs.callPackage ../lib {});
  ssh_pub = (import ../base/ssh_pub.nix);
  rtable = "up_vpn";
  ifname = "tun_up";
  cdir = "/etc/openvpn/up";
  frClear = pkgs.writeShellScript "clear_routes" ''
    PATH=$PATH:${pkgs.iproute2}/bin
    ip route flush table "${rtable}"
    ip route add throw 10.17.0.0/16 table "${rtable}"
    ip route add throw 10.231.0.0/16 table "${rtable}"
    ip route add table up_vpn blackhole default
'';
  frSet = pkgs.writeShellScript "set_routes" ''
    PATH=$PATH:${pkgs.iproute2}/bin
    ip route flush table "${rtable}"
    ip route add "''${route_vpn_gateway}" dev "${ifname}"
    ip route add throw 10.17.0.0/16 table "${rtable}"
    ip route add throw 10.231.0.0/16 table "${rtable}"
    ip route add table "${rtable}" default via "''${route_vpn_gateway}"
'';
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
    "net.ipv4.ip_forward" = mkForce true;
    "net.ipv4.conf.all.forwarding" = mkForce true;
  };
  
  networking = {
    firewall.enable = false;
    iproute2 = {
      enable = true;
      rttablesExtraConfig = "16 ${rtable}";
    };
    defaultGateway.address = upAddr;
    localCommands = ''
${pkgs.openvpn}/bin/openvpn --mktun --dev "${ifname}"
ip rule add from "${cAddr}" lookup "${rtable}" 
'';

    nftables = {
      enable = true;
      ruleset = ''
flush ruleset

table ip filter0 {
  chain input {
    type filter hook input priority filter
    policy drop
    iif "eth0" counter accept
    counter drop
  }

  chain output {
    type filter hook output priority filter
    policy drop
    oif "eth0" counter accept
    counter drop
  }

  chain forward {
    type filter hook forward priority 0
    policy drop
    iif "eth0" oifname "${ifname}" counter accept
    tcp dport { 22 } counter drop
    iifname "${ifname}" oif "eth0" counter accept
    counter drop
	}
}

table ip nat {
	chain postrouting {
    type nat hook postrouting priority srcnat;
    oifname "${ifname}" masquerade
	}

	chain dnats {
    udp dport {54921} counter dnat to ${cAddr}
    tcp dport {54921} counter dnat to ${cAddr}
	}

	chain prerouting {
    type nat hook prerouting priority dstnat;
    iifname "${ifname}" ct state { new } goto dnats
	}
}
'';
    };
  };

  services = {
    openssh.enable = mkForce false;
    openvpn.servers.up.config = ''
client
proto udp
dev ${ifname}
cd ${cdir}/

float
resolv-retry infinite
persist-key
persist-tun
remote-cert-tls server
reneg-sec 0
fast-io

script-security 2
route-noexec
route-up ${frSet}
down ${frClear}
auth-retry nointeract

ping 10
ping-restart 60

config ${cdir}/config
'';
  };

  environment.systemPackages = with (import ../pkgs {}); sysPkgs;
}
