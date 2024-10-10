{pkgs, ...}:
let
  inherit (pkgs.lib) intersperse concatStrings;
in rec {
  conf_simple = ports: let
    inPortStr = concatStrings (intersperse "," (map toString ports));
  in (''
flush ruleset;

table inet filter0 {
	chain a_input {
		type filter hook input priority 0; policy accept;
		iifname "lo" counter accept 
		iifname "eth_lan" counter goto ext_in
		iifname "eth_wifi" counter goto notnew
	}

	chain a_output {
		type filter hook output priority 0; policy accept;
	}

	chain a_forward {
		type filter hook forward priority 0; policy accept;
		oifname "ve-prsw-net" counter accept
		iifname "ve-prsw-net" counter accept

		iifname "eth_lan" counter goto notnew
		iifname "eth_wifi" counter goto notnew

		iifname "ve-prsw" goto block
		iif "c_wg0" goto wg0_in
	}

  chain c_wg0 {
		tcp dport {${inPortStr}} counter accept
		counter goto notnew
  }

	chain ext_in {
		ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem} counter accept
		ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded, echo-request} counter accept
		tcp dport {${inPortStr}} counter accept
		tcp dport {22,7777} counter accept
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
table ip nat {
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
		oifname "eth_lan" masquerade
		oifname "eth_wifi" masquerade
	}

  chain dnats {
	  udp dport 32320 dnat 10.231.1.4 # aiwar
		tcp dport {20000-20020} dnat 10.231.1.4
		udp dport {20000-20020} dnat 10.231.1.4
  }

	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
		iifname "eth_lan" ct state new goto dnats;
	}
}

'');

  conf_terminal = (conf_simple []);
  env_conf_terminal = {
    "nft.conf" = {
      text = (conf_terminal);
    };
  };

  systemd.network.netdevs."c_wg0" = {
    netdevConfig = {
      Kind = "tun";
    };
  };
  
  services = {
    SH_nft_setup = {
      restartIfChanged = true;
      path = [pkgs.nftables];
      wantedBy = ["network.target"];
      description = "SH NFT setup";
      script = ''
# Initialize nft rules
C=/etc/nft.conf
[ ! -f $C ] && exit 0
modprobe nft_chain_nat_ipv4 || true

nft delete table inet filter0 2>/dev/null || true
nft delete table nat 2>/dev/null || true
nft -f $C || true
'';
    };
  };
}
