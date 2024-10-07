{pkgs, lib, l, ...}:
let
  inherit (builtins) toString;
  inherit (lib.strings) concatStrings;
  inherit (lib.attrsets) mapAttrsToList;
  port = 51820;
  ifn = "c_wg0";

  s = x: "${x}.service";
  sn0 = "SH_${ifn}_wireguard-go";
  
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
  conf = concatStrings (mapAttrsToList h2cs l.hostsTable);
  cnfFile = builtins.toFile "wireguard-conf" conf;

in {
  environment.systemPackages = with pkgs; [ wireguard-tools wireguard-go ];
  services.prometheus.exporters.wireguard = {
    enable = true;
    port = 9102;
  };
  # systemd.network.netdevs does not appear to support boringtun-managed wg0 interfaces at present.
  # Instead, just use it to create the tun iface and do our own stuff on top.
  systemd.network = let
    addr = l.hostRec.addr;
  in {
    netdevs."${ifn}" = {
      netdevConfig = {
        Name = ifn;
        Kind = "tun";
      };
    };
    
    networks.wireguard = {
      enable = true;
      matchConfig = { Name = ifn; };
      networkConfig.Description = "local wireguard overlay network";
    } // (if (addr == null) then {} else {
      address = [(addr."${ifn}" + "/64")];
    });
  };

  users = l.lib.mkUserGroups (with l.vars.userSpecs {}; [wireguard]);

  systemd.tmpfiles.settings = {
    "wireguard"."/var/run/wireguard".d = {
      group = "root";
      user = "wireguard";
      mode = "0755";
    };
  };
  
  systemd.services = {
    "${sn0}" = {
      after = ["network.target"];
      serviceConfig = let
        caps = "CAP_NET_ADMIN";
      in {
        Restart = "on-failure";
        RemainAfterExit = "yes";
        User = "wireguard";
        CapabilityBoundingSet = caps;
        AmbientCapabilities = caps;
        NoNewPrivileges = "yes";
      };
      path = [pkgs.wireguard-go];
      script = ''
       export WG_PROCESS_FOREGROUND=1
       exec wireguard-go -f "${ifn}"
      '';
    };
    "SH_${ifn}_conf" = {
      after = [(s sn0) "network.target" ];
      wantedBy = [(s sn0) "multi-user.target" ];
      requires = [(s sn0)];
      serviceConfig = {
        Restart = "on-failure";
        RemainAfterExit = "yes";
      };
      path = [pkgs.wireguard-tools];
      script = ''
        echo 'Synching config: ${cnfFile}'
        wg syncconf "${ifn}" "${cnfFile}"
        wg set "${ifn}" listen-port ${toString port} private-key "/etc/wireguard/x.key"
      '';
    };
  };
}
