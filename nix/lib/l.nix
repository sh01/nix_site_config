{hostc, hostname}: {lib, config, pkgs, ...}:
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
    inherit lib config pkgs call l;
  };

  _sites = call ../base/sites.nix {};

  wi = "wi";
  # By-host constant configuration. These are split out here over being kept in
  # per-host config files to make sanity verification and mass edits easier.
  _hostsData = {
    "bw0" = [null wi];
    "uiharu" = [6 wi];
    "keiko" = [null wi];
    "liel" = [null wi];
    "nova" = [null wi];

    "jibril" = [null wi];
    "yalda" = [null wi];
  };

  # Host-specific variables
  _hostData = _hostsData."${hostname}";
  _hostIdx = elemAt _hostData 0;
  _nixHostId = fixedWidthString 8 "0" (toHexString (65536 + _hostIdx));

  # Will be passed as argument "l" to host configs and anything below called via l.call.
  l = rec {
    inherit call hostname;
    lib = call ../lib {};
    vars = call ../base/vars.nix {};
    defaultConf = call (import ../base);
    
    site = _sites."${elemAt _hostData 1}";
    siteConf = site.config;
    
    netHostInfo = {
      hostName = hostname;
      hostId = _nixHostId;
    };

    ifaceDmz = site.mkIface _hostIdx;
  };
in autoArgs
