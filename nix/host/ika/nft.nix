{...}: ''
table inet filter0 {
	chain a_input {
		type filter hook input priority 0; policy accept;
		iif "lo" counter accept
		iif "eth0" counter goto ext_in
		iif "c_wg0" counter goto wg0_in
	}
	chain a_output {
		type filter hook output priority 0; policy accept;
	}
	chain a_forward {
		type filter hook forward priority 0; policy accept;
		iif "eth0" counter
	}
  chain wg0_in {
		tcp dport 22 counter accept
		ip6 saddr fd9d:1852:3555:101:0000::20 counter accept
		tcp dport 9100-9101 counter accept
		counter goto notnew
  }
	chain ext_in {
		ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem} counter accept
    ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded} counter accept
    tcp dport 22 counter accept
    udp dport 51820 counter accept
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
	}
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
	}
}
table ip6 nat {
	chain prerouting {
		type nat hook prerouting priority 0; policy accept;
	}
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
	}
}
''
