#!@bash@/bin/bash
export PATH=@iproute@/bin

# Do openvpn interface setup.
# This is designed to do the right thing for pure-ipv6 tun interfaces, since
# openvpn by itself does neither bring those up nor assign addresses to them.
ip link set dev $dev up mtu 1500
ip -6 addr add $ifconfig_ipv6_local/$ifconfig_ipv6_netbits dev $dev
