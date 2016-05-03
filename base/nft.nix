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
		iifname "ve-prsw" goto block 
		iifname "eth_lan" goto notnew
		iifname "eth_wifi" goto notnew
	}

	chain ext_in {
		tcp dport {${inPortStr}} counter accept
		goto notnew 
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
'');

  conf_terminal = (conf_simple [22]);

  services = {
    SH_nft_setup = {
      restartIfChanged = true;
      path = [pkgs.nftables];
      wantedBy = ["network-pre.target"];
      description = "SH NFT setup";
      script = ''
# Set up container dirs
C=/etc/nft.conf
[ ! -f $C ] && exit 0

nft delete table inet filter0 || true
nft -f $C || true
'';
    };
  };
}
