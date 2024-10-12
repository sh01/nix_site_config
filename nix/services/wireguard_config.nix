{l, lib, ...}:
let
  inherit (builtins) toString;
  inherit (lib.strings) concatStrings;
  inherit (lib.attrsets) mapAttrsToList;
  hostsTable = (import ../lib/hosts_table.nix {inherit lib;});
  
  port = 51820;
  
  confSec = {hn, key, pAddr, cAddr, extra}: if (key == null) || (cAddr == null) || (hn == l.hostname) then "" else
    "# ${hn}\n" + ''
    [Peer]
    PublicKey = ${key}
    AllowedIps = ${cAddr}/128
    '' + (if (pAddr == null) then "" else ''
    Endpoint = [${pAddr}]:${toString port}
    '' + extra);
  
  isMySite = r: r.site.name == l.site.name;
  h2cs = n: r: if (r.addr == null) || !(l.hostRec.wgWantPeer r) then "" else
    let
      addr = if (isMySite r) then r.addr.local else r.addr.global;
      extra = if ((isMySite r) || (l.hostRec.addr.global != null)) then "" else ''
      '';
      #PersistentKeepalive = 116
    in confSec {inherit extra; hn=n; key=r.pub.wireguard; cAddr=r.addr.c_wg0; pAddr=addr;};
  conf = concatStrings (mapAttrsToList h2cs hostsTable);
  file = builtins.toFile "wireguard-conf" conf;
in {
  inherit port file;
}
