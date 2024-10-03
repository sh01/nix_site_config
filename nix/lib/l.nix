{hostc, hostname}: {lib, config, pkgs, system, ...}:
let
  inherit (builtins) elemAt;
  inherit (lib.strings) fixedWidthString;
  inherit (lib.trivial) toHexString;

  callWith = autoargs: fn: args:
    let
      f = if lib.isFunction fn then fn else import fn;
    in (f (autoargs // args));
  call = (callWith autoArgs);

  autoArgs = {
    inherit lib config pkgs call l system;
  };

  _sites = call ../base/sites.nix {};

  wi = "wi";
  # By-host constant configuration. These are split out here over being kept in
  # per-host config files to make sanity verification and mass edits easier.
  _hostsTable = (call ./hosts_table.nix {});

  # Host-specific variables
  _hostData = _hostsTable."${hostname}";
  _hostIdx = _hostData.idx;
  _nixHostId = fixedWidthString 8 "0" (toHexString (65536 + _hostIdx));
  _dns = (import ../base/dns.nix);

  # Will be passed as argument "l" to host configs and anything below called via l.call.
  l = rec {
    inherit call hostname;
    lib = call ../lib {};
    vars = call ../base/vars.nix {};
    dns = call _dns site.dns_params;
    
    site = _sites."${_hostData.site}";
    conf = {
      site = site.config;
      default = call (import ../base);
    };

    srv = {
      prom_exp_node = call ../services/prom_exp_node.nix {};
      wireguard = call ../services/wireguard.nix {};
    };
    
    netHostInfo = {
      hostName = hostname;
      hostId = _nixHostId;
    };

    hostsTable = _hostsTable;
    ifaceDmz = site.mkIface _hostIdx;
    netX = site.mkNet _hostIdx;
  };
in autoArgs
