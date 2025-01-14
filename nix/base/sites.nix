{lib, ...}:
let
  inherit (lib.trivial) toHexString;
  inherit (lib.attrsets) mapAttrs';
  wg_bw0 = "fd9d:1852:3555:101::1";
in mapAttrs' (n: v: {
  name = n;
  value = v // {name=n;};
}) {
  "wi" = rec {
    mkIface = num: {
      ipv4.addresses = [{ address = "10.17.1.${toString num}"; prefixLength = 24; }];
      ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
      ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::${toHexString num}"; prefixLength=64;}];
    };
    net = num: rec {
      addr = {
        local = "fd9d:1852:3555:200:ff01::${toHexString num}";
        c_wg0 = if (num == null) then null else "fd9d:1852:3555:0101::${toHexString num}";
      };
      systemd = ifname: {
        networks = {
          "x" = {
            matchConfig = { Name = ifname; };
            networkConfig = {
              Description = "wi-x network";
              ConfigureWithoutCarrier = true;
            };
            enable = true;
            address = ["10.17.1.${toString num}/24" "${addr.local}/64"];
            routes = [{
              routeConfig.Gateway = "10.17.1.1";
            }];
          };
        };
      };
    };
    config = {
      time.timeZone = "America/Chicago";
    };
    srvs = {
      ntp = [wg_bw0];
    };
    dns_params = { nameservers = [wg_bw0]; searchPath = [ "s" "x.s" "sh.s" "wifi.s" ];};
  };
  "global" = {
    config = {
      time.timeZone = null;
    };
    net = num: {
      addr = {
        local = null;
        c_wg0 = "fd9d:1852:3555:0101:ff00::${toHexString num}";
      };
    };
  };
  "stellvia".config = {
    time.timeZone = "Europe/Dublin";
  };
  "wl".config = {
    time.timeZone = "America/Los_Angeles";
  };
}
