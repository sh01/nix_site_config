{lpkgs, bash, iproute, callPackage, ...}:
let
  ca = ../../data/vpn-o/ca.crt;
  crt = ../../data/vpn-o/s_ika.crt;
  dh = ./dh_vpn-o;
  ccs = (callPackage ../../pkgs/pkgs/openvpn_map_client {
    netmask="255.255.255.0";
    clients=[
      "'uiharu.vpn-o.sh.s': mkaddr('10.16.132.2')"
      "'likol.vpn-o.sh.s': mkaddr('10.16.132.3')"
      "'allison.vpn-o.sh.s': mkaddr('10.16.132.128')"
    ];
  });
  name = "ocean";
  iface_sx = "o";
  sys_scripts = lpkgs.SH_sys_scripts;
in ''
port 1210
proto udp

dev tun_vpn_${iface_sx}
float

cipher AES-256-CBC

ca ${ca}
cert ${crt}
dh ${dh}
key /var/auth/vpn_${name}.key

ifconfig 10.16.132.1 10.16.132.0
route 10.16.132.0 255.255.255.0
client-connect "${ccs}/bin/SH_openvpn_map_client"
push "route 10.16.132.1"

script-security 2
up ${sys_scripts}/bin/sh_ovpn_setup_iface.sh
tun-ipv6
push tun-ipv6
ifconfig-ipv6 fd9d:1852:3555:0102::1/64 fd9d:1852:3555:0102::
route-ipv6 fd9d:1852:3555:0102::/64
push "route-ipv6 fd9d:1852:3555:0102::1"

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
