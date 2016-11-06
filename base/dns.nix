{searchPath ? [ "sh.s" "baughn-sh.s" ], nameservers4 ? [ "10.16.0.1" ]}: rec {
  conf = {
    search = searchPath;
    nameservers = nameservers4;
  };

  mkResolvConf = sp: ns: let
    sps = builtins.foldl' (a: b: a + " " + b) "" sp;
    nss = builtins.foldl' (a: b: a + " " + b) "" ns;
  in {
    text = ''
search ${sps}
nameserver ${nss}
'';
  };
  resolvConf = (mkResolvConf searchPath nameservers4);
}
