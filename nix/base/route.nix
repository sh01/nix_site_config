# Set up static route config for vpn shenanigans.
{pkgs, ...}:
{
  services = {
    SH_route_setup = {
      restartIfChanged = true;
      path = [pkgs.iproute];
      wantedBy = ["network.target"];
      description = "SH route setup";
      script = ''
# Set up container dirs
LNET="fd9d:1852:3555::/48"
LNET_VPN="fd9d:1852:3555:0101::/64"

ip -6 route add throw $LNET_VPN table memespace
ip -6 route add unreachable $LNET metric 128 table memespace
ip -6 rule add pref 1024 table memespace
'';
    };
  };
}
