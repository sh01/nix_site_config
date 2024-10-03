{lib, ...}:
let
  inherit (lib.trivial) toHexString;
in {
  "wi" = rec {
    mkIface = num: {
      ipv4.addresses = [{ address = "10.17.1.${toString num}"; prefixLength = 24; }];
      ipv4.routes = [{ address = "0.0.0.0"; prefixLength = 0; via = "10.17.1.1"; }];
      ipv6.addresses = [{ address = "fd9d:1852:3555:200:ff01::${toHexString num}"; prefixLength=64;}];
    };
    net = num: rec {
      addr = {
        local = "fd9d:1852:3555:200:ff01::${toHexString num}";
        c_wg = "fd9d:1852:3555:0101::${toHexString num}";
      };
      systemd = ifname: {
        networks = {
          "x" = {
            matchConfig = { Name = ifname; };
            networkConfig.Description = "wi-x network";
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
    dns_params = { nameservers4 = ["10.17.1.1"];};
  };
  "stellvia".config = {
    time.timeZone = "Europe/Dublin";
  };
  "wl".config = {
    time.timeZone = "America/Los_Angeles";
  };
}
