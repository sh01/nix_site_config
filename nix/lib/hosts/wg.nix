{l, lib, ...}: let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStrings;
  inherit (builtins) toFile;
  h2he = _: r:
    if (r.addr == null) || (r.addr.c_wg0 == null) then "" else "${r.addr.c_wg0} ${r.name}.wg.s.\n";
  hostsText = concatStrings (mapAttrsToList h2he l.hostsTable);
  hostsFile = toFile "hosts-wg" hostsText;
in {
  networking.hostFiles = [hostsFile];
}
