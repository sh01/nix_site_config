{searchPath, nameservers, ...}: rec {
  conf = {
    inherit nameservers;
    search = searchPath;
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
