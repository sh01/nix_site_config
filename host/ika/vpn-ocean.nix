{lpkgs, bash, iproute, ...}:
let
  ca = ../../data/vpn-o/ca.crt;
  crt = ../../data/vpn-o/s_ika.crt;
  dh = ./dh_vpn-o;
  sys_scripts = lpkgs.SH_sys_scripts;
in ''
port 1210
proto udp

dev tun_vpn_o
float

cipher AES-256-CBC

ca ${ca}
cert ${crt}
dh ${dh}
key /var/auth/vpn_ocean.key

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

status /var/local/run/openvpn/ocean.status
''
