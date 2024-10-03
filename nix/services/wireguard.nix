{pkgs, ...}:
let
  ifn = "c_wg0";
  s = x: "${x}.service";
  sn0 = "SH_${ifn}_wireguard-go";
in {
  environment.systemPackages = with pkgs; [ wireguard-tools wireguard-go boringtun ];
  services.prometheus.exporters.wireguard = {
    enable = true;
    port = 9102;
  };
  # systemd.network.netdevs does not appear to support boringtun-managed wg0 interfaces at present.
  # Instead, just use it to create the tun iface and do our own stuff on top.
  systemd.network.netdevs."${ifn}" = {
    netdevConfig = {
      Name = ifn;
      Kind = "tun";
    };
    tunConfig = {
      #User = "sh";
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
        User = "__TODO";
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
        wg set "${ifn}" listen-port 51820 private-key "/etc/wireguard/x.key"
      '';
    };
  };
}
