{ stdenv, fetchurl, pkgconfig, bison, flex
, libmnl, libpcap
, gmp, jansson, readline
, withXtables ? false , iptables
}:

with stdenv.lib;
let
 libnftnl = stdenv.mkDerivation rec {
  version = "1.1.4";
  name = "libnftnl";

  src = fetchurl {
    url = "https://netfilter.org/projects/${name}/files/${name}-${version}.tar.bz2";
    sha256 = "087dfc2n4saf2k68hyi4byvgz5grwpw5kfjvmkpn3wmd8y1riiy8";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libmnl ];

  meta = with stdenv.lib; {
    description = "A userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem";
    homepage = http://netfilter.org/projects/libnftnl;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ];
  };
};
in stdenv.mkDerivation rec {
  version = "0.9.2";
  name = "nftables";

  src = fetchurl {
    url = "https://netfilter.org/projects/nftables/files/${name}-${version}.tar.bz2";
    sha256 = "1x8kalbggjq44j4916i6vyv1rb20dlh1dcsf9xvzqsry2j063djw";
  };

  configureFlags = [
    "--disable-man-doc"
    "--with-json"
  ] ++ optional withXtables "--with-xtables";

  nativeBuildInputs = [ pkgconfig bison flex ];

  buildInputs = [
    libmnl libnftnl libpcap
    gmp readline jansson
  ] ++ optional withXtables iptables;

  meta = {
    description = "The project that aims to replace the existing {ip,ip6,arp,eb}tables framework";
    homepage = "https://netfilter.org/projects/nftables/";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
