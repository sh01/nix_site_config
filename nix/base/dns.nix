{searchPath ? [ "s" "x.s" "sh.s" "wifi.s" ], nameservers ? [ "10.17.1.1" ], ...}: rec {
  conf = {
    search = searchPath;
    inherit (nameservers);
  };

  mkResolvConf = sp: ns: let
    sps = builtins.foldl' (a: b: a + " " + b) "" sp;
    nss = builtins.foldl' (a: b: a + "nameserver " + b + "\n") "" ns;
  in {
    text = ''
search ${sps}
${nss}
'';
  };
  resolvConf = (mkResolvConf searchPath nameservers);
  resolvConfCont = (mkResolvConf searchPath ["10.231.1.1"]);
}
