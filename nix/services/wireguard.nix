{pkgs, lib, l, ...}:
let
  inherit (builtins) toString;
  ifn = "c_wg0";

  s = x: "${x}.service";
  sn0 = "SH_${ifn}_wireguard-go";

  conf = (l.call ./wireguard_config.nix {});

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
        echo 'Synching config: ${conf.file}'
        wg syncconf "${ifn}" "${conf.file}"
        wg set "${ifn}" listen-port ${toString conf.port} private-key "/etc/wireguard/x.key"
      '';
    };
  };
}
