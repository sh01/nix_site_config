{pkgs, ...}:
let
  inherit (pkgs.lib) intersperse concatStrings;
  mkFile = text: {
    "nft.conf" = {
      text = text;
    };
  };
in rec {
  conf_simple = ports: let
    inPortStr = concatStrings (intersperse "," (map toString ports));
  in (mkFile ''
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
		iifname "eth_lan" counter goto notnew
		iifname "eth_wifi" counter goto notnew

		oifname "ve-prsw_net" counter accept
		iifname "ve-prsw_net" counter accept

		iifname "ve-prsw" goto block
	}

	chain ext_in {
		ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem} counter accept
		ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded} counter accept
		tcp dport {${inPortStr}} counter accept
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

	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
		udp dport 32320 dnat 10.231.1.4 # aiwar
	}
}

'');

  conf_terminal = (conf_simple [22]);

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
