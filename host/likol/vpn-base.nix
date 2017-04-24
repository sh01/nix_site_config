{lpkgs, bash, iproute, callPackage, ...}:
let
  ca = ../../data/vpn-base/ca.crt;
  crt = ../../data/vpn-base/s_likol.crt;
  dh = ./dh_vpn-base;
  ccs = (callPackage ../../pkgs/pkgs/openvpn_map_client {
    gateway4="10.16.129.1";
    gateway6="fd9d:1852:3555:0101:1000::1";
    clients=[
      "'allison.vpn.sh.s': mkaddr('10.16.129.4', 'fd9d:1852:3555:101:1000::4')"
      "'rune.vpn.sh.s': mkaddr('10.16.129.5', 'fd9d:1852:3555:101:1000::5')"
    ];
  });
  name = "base";
  iface_sx = "b";
  sys_scripts = lpkgs.SH_sys_scripts;
in ''
port 1200
proto udp
# Quick and dirty, try to avoid outside-tunnel fragmentation during double-tunneling
tun-mtu 1400

dev tun_vpn_${iface_sx}
float

cipher AES-256-CBC

ca ${ca}
cert ${crt}
dh ${dh}
key /var/auth/vpn_${name}.key

ifconfig 10.16.129.1 10.16.129.0
route 10.16.129.0 255.255.255.0
client-connect "${ccs}/bin/SH_openvpn_map_client"
push "route 10.16.129.1"

script-security 2
up ${sys_scripts}/bin/sh_ovpn_setup_iface.sh
tun-ipv6
push tun-ipv6
ifconfig-ipv6 fd9d:1852:3555:0101:1000::1/64 fd9d:1852:3555:0101:1000::
route-ipv6 fd9d:1852:3555:0101:1000::/64

mode server
tls-server
keepalive 60 250

max-clients 16

user openvpn
group openvpn

persist-key
persist-tun

status /var/local/run/openvpn/${name}.status
''
