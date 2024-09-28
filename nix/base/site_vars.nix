{lib, ...}:
let
  inherit (lib.trivial) toHexString;
in {
  "wi" = {
    mkIface = num: {
      ipv4.addresses = [{ address = "10.17.1.${toString num}"; prefixLength = 24; }];
      ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
      ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::${toHexString num}"; prefixLength=64;}];
    };
    config = {
      time.timeZone = "America/Chicago";
    };
  };
}
