{ pkgs, lib, clients, gateway4, gateway6, ...}:

pkgs.substituteAll {
  name = "SH_openvpn_map_client";
  dir = "bin";
  python = pkgs.python;
  inherit gateway4 gateway6;
  client_config = lib.strings.concatStringsSep ",\n" clients;

  src = ./openvpn_map_client.py;
  isExecutable = true;
}
