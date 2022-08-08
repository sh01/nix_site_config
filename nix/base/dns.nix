{searchPath ? [ "sh.s" "baughn-sh.s" ], nameservers4 ? [ "10.17.1.1" ]}: rec {
  conf = {
    search = searchPath;
    nameservers = nameservers4;
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
  resolvConf = (mkResolvConf searchPath nameservers4);
  resolvConfCont = (mkResolvConf searchPath ["10.231.1.1"]);
}
