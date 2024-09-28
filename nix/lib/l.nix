{hostc, hostname}: {lib, config, pkgs, ...}:
let
  inherit (builtins) elemAt;
  callWith = autoargs: fn: args:
    let
      f = if lib.isFunction fn then fn else import fn;
    in (f (autoargs // args));
  call = (callWith autoArgs);

  autoArgs = {
    inherit lib config pkgs call l;
  };

  _hostsData = {
    "uiharu" = ["84d5fccd" 6 "wi"];
  };

  _hostData = _hostsData."${hostname}";
  _hostIdx = elemAt _hostData 1;
  _sites = call ../base/site_vars.nix {};

  l = rec {
    inherit hostname;
    lib = call ../lib {};
    vars = call ../base/vars.nix {};
    defaultConf = call (import ../base);
    
    site = _sites."${elemAt _hostData 2}";
    siteConf = site.config;
    
    netHostInfo = {
      hostName = hostname;
      hostId = elemAt _hostData 0;
    };

    ifaceDmz = site.mkIface _hostIdx;
  };
in autoArgs
