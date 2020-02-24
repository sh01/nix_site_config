# Ika is a small traffic-routing cloud deployment.
# Manual setup things:
#  /var/spool . go+rx (uptimed)
#  /var/local/run/openvpn openvpn:openvpn

{ config, lib, pkgs, ... }:
let
  inherit (pkgs) callPackage;
  inherit (lib) mkForce;
  lpkgs = (import ../../pkgs {});
  slib = import ../../lib;
  ssh_pub = import ../../base/ssh_pub.nix;
  nft = callPackage ../../base/nft.nix {};
  vars = import ../../base/vars.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ./nixos-in-place.nix
    ../../base
    ../../base/nox.nix
    ./kernel.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  boot.kernelPackages = pkgs.linuxPackages_4_8;
  
  networking = {
    hostName = "ika";
    hostId = "84d5fcc9";
    useDHCP = false;
    firewall.enable = false;
    iproute2 = vars.iproute2;
  };

  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); with lpkgs; [
    base
    cliStd
    nixBld
    SH_sys_scripts
    uptimed
  ];

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
  
  environment.etc."nft.conf".text = ''
table inet filter0 {
	chain a_input {
		type filter hook input priority 0; policy accept;
		iif "lo" counter accept
		iifname "tun_vpn_o" counter accept
		iifname "tun_vpn_ms" counter accept
		iif "eth0" counter goto ext_in
	}
	chain a_output {
		type filter hook output priority 0; policy accept;
	}
	chain a_forward {
		type filter hook forward priority 0; policy accept;
		iif "eth0" counter
		iifname "tun_vpn_o" counter
	}
	chain ext_in {
		ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem} counter accept
		ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded} counter accept
		udp dport 1210 counter accept # ocean vpn
		tcp dport 22 counter goto block
		counter goto notnew
	}
	chain notnew {
		ct state { established, related} accept
		goto block
	}
	chain block {
		meta l4proto tcp counter reject with tcp reset
		counter reject
		counter drop
	}
}
# NFT DNAT on incoming doesn't mangle source addresses; for that, we also need SNAT on the outgoing iface.
table ip nat {
	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
		iif "eth0" udp dport 1200 dnat 10.16.132.3 # likol vpn
	}
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
		oifname "tun_vpn_o" masquerade
	}
}
table ip6 nat {
	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
		iif "eth0" udp dport 1200 dnat fd9d:1852:3555:0102::3 # likol vpn
	}
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
		oifname "tun_vpn_o" masquerade
	}
}
'';
  systemd.services = nft.services;

  sound.enable = false;
  security.polkit.enable = false;

  # Services config
  services = {
    udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="6a:8b:f8:44:c1:44", KERNEL=="eth*", NAME="eth0"
    '';
  
    openssh.enable = true;
    openssh.moduliFile = ./sshd_moduli;

    openvpn.servers = {
      vpn-ocean = {
        config = (pkgs.callPackage ./vpn-ocean.nix {lpkgs = lpkgs;});
      };
    };
    uptimed.enable = true;
  };
  security.pam.services = {
    su.requireWheel = true;
  };

  users = slib.mkUserGroups (with vars.userSpecs {}; default ++ [openvpn]);
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
