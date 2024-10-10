{inPortStr,...}: ''
flush ruleset;

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

  chain wg0_in {
    # Prometheus exporters
    ip6 saddr fd9d:1852:3555:101:0000::1 tcp dport 9100-9101 counter accept
    ip6 saddr fd9d:1852:3555:101:0000::0/80 counter goto ext_in
    ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded, echo-request} counter accept
    ip6 saddr fd9d:1852:3555:101:ff00::0/80 counter goto notnew
    ip version 4 counter goto block
    counter goto block
  }

	chain ext_in {
		ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded, parameter-problem} counter accept
		ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, packet-too-big, nd-neighbor-advert, destination-unreachable, nd-router-advert, time-exceeded, echo-request} counter accept
		tcp dport {${inPortStr}} counter accept
    udp dport {51820} counter accept
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
''
