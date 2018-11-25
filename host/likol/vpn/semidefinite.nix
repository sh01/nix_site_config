rec {
  ca = ../../../data/vpn-semidefinite/ca.crt;
  crt = ../../../data/vpn-semidefinite/c_uiharu.crt;
  key = "/var/auth/vpn_semidefinite_uiharu.key";
  config = ''
tls-client
#remote vpn.semidefinite.de #213.95.21.38 at time of writing
remote 89.238.64.58
verb 3
dev tun_vpn_zefi
ifconfig 10.2.0.2 10.2.0.3
route 213.95.21.206 255.255.255.255 vpn_gateway
route 10.0.0.0 255.255.255.0 vpn_gateway
route 10.174.247.0 255.255.255.0 vpn_gateway
#route 139.174.247.222 255.255.255.255 vpn_gateway
#route 139.174.247.145 255.255.255.255 vpn_gateway
#route 139.174.247.156 255.255.255.255 vpn_gateway
#link-mtu 1492
tun-mtu 1423
port 1600
user nobody
group nogroup
persist-key
persist-tun
persist-local-ip

ca ${ca}
cert ${crt}
key ${key}

keepalive 5 60

status /var/run2/openvpn/zefiris.status
'';
}
