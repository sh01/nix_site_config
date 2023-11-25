{ pkgs, ... }:
let
  inherit (pkgs) callPackage;
  cont = callPackage ../../containers {};
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
      ruleset = nft.conf_simple [22 9100];
    };
    # Push this way out of the way.
    #resolvconf.extraConfig = "resolv_conf=/etc/__resolvconf.out";
  };
  #environment.etc."resolv.conf" = dns.resolvConf;
  environment.systemPackages = [(callPackage ../../pkgs/pkgs/meta {}).gamingBox];
  environment.etc = nft.env_conf_terminal;

  services = {
    xserver = {
      videoDrivers = ["intel" "amdgpu"];
      desktopManager = {
        xfce = {
          enable = true;
          enableScreensaver = false;
        };
      };
    };
    uptimed.enable = true;
    prometheus.exporters.node = (import ../../base/node_exporter.nix);
    ntp = {
      enable = true;
      servers = ["10.17.1.1"];
    };
  };

  programs.ssh.extraConfig = cont.sshConfig;
  systemd.services = cont.termS;
}
