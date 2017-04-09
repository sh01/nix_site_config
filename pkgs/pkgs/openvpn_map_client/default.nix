{ pkgs, netmask, lib, clients, ...}:

pkgs.substituteAll {
  name = "SH_openvpn_map_client";
  dir = "bin";
  python = pkgs.python;
  inherit netmask;
  client_config = lib.strings.concatStringsSep ",\n" clients;

  src = ./openvpn_map_client.py;
  isExecutable = true;
}
