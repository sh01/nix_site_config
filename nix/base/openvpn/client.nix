{...}: {
  ocean = {
    remote0 = "138.68.246.52 1210 udp";
    remote1 = "ika.memespace.net 1210 udp";
    ca = ../../data/vpn-o/ca.crt;
    key = "/var/auth/vpn_ocean.key";
  };
  config = {remote0, remote1, ca, cert, key}: ''
client
dev tun_vpn_o
float

remote ${remote0}
remote ${remote1}

ca ${ca}
cert ${cert}
key ${key}

script-security 1
cipher AES-256-CBC
keepalive 10 120

user openvpn
group openvpn
persist-key
persist-tun

ns-cert-type server

status /var/local/run/openvpn/ocean.status
'';
}
