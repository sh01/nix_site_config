{ config, pkgs, l, ... }:
let
  inherit (pkgs) callPackage;
  cont = l.call ../../containers {};
  nft = callPackage ../../base/nft.nix {};
in {
  imports = [
    ../sys_pulseaudio.nix
    ../sys_pulseaudio_user.nix
  ];
  networking = {
    usePredictableInterfaceNames = false;
    useDHCP = false;
    firewall.enable = false;
    networkmanager.enable = false;
    useNetworkd = false;

    nameservers = ["10.17.1.1"];
    search = ["x.s." "s."];

    nftables = {
      enable = true;
      ruleset = (nft.conf_simple config.l.ext_ports_t);
    };
    # Push this way out of the way.
    #resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
  };
  #environment.etc."resolv.conf" = dns.resolvConf;
  environment.systemPackages = [(callPackage ../../pkgs/pkgs/meta {}).gamingBox];

  services = {
    xserver.videoDrivers = ["intel" "amdgpu"];
    uptimed.enable = true;
    ntp = {
      enable = true;
      servers = ["10.17.1.1"];
    };
  };

  programs.ssh.extraConfig = cont.sshConfig;
  systemd.services = cont.termS;
}
