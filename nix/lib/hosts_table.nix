# Declarative host data shared with all hosts for inter-host communication.
{lib, ...}: let
  inherit (builtins) foldl';
  inherit (lib) lists;
  sites = import ../base/sites.nix {inherit lib;};

  HN = s: [s "${s}.sh.s." "${s}.sh.s" "${s}.vpn.sh.s." "${s}.vpn.sh.s"];
  hostRecord = {
    hn, idx, hk_ssh ? "ssh-ed25519 _NOKEY", hk_wg ? null, site_name ? null, names ? HN hn, addr_global ? null,
    wg_want_peer ? (x: false)
  }: {
    "${hn}" = rec {
      inherit idx names;
      name = hn;
      pub = {
        ssh = hk_ssh;
        wireguard = hk_wg;
      };
      wgWantPeer = wg_want_peer;

      site = if (site_name == null) then null else sites."${site_name}";
      net = if (site == null) then null else (site.net idx);
      addr = if (site == null) then null else ((site.net idx).addr // {
        global = addr_global;
      });
    };
  };
  aB = idx: hn: {
    inherit hn idx;
  };
  aNames = n: { names = n; };
  aSSH = k: {hk_ssh = k; };
  aSSHed = k: aSSH ("ssh-ed25519 ${k}");
  aSite = site: {site_name=site;};
  aAddrG = addr: {addr_global = addr;};

  rWgPeers = l: {wg_want_peer = p: (lists.findFirstIndex (x: x == p.name) null l) != null;};
  rWgPeersAll = {wg_want_peer = p: true;};
  
  s = {
    wi = aSite "wi";
    g = aSite "global";
  };

  wgk = k: {
    hk_wg = k;
  };
  peersB = ["bw0" "allison"];

in (foldl' (l: row: let
  args = foldl' (a: b: a // b) {} row;
  hrec = hostRecord args;
in (l // hrec)) {} [
  # wi
  [s.wi (aB 1 "bw0") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAICM1FxTZk1oV5gEz70x9q6ahbeScWgg2lTKXStAgn3XM") (aNames ["bw0" "bw0.ulwired-ctl.s."]) (wgk "7pJzA4qLMCBvuljlndZHAWFJUlNwtwbBrgS7KMrml2E=") rWgPeersAll]
  [s.wi (aB 32 "allison") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIGE+YvDLKwJ9SEm4NgYOELl0TWomv3fGSA7fwLjDWI9I") (wgk "FilBW9G65SPZ+l6OSJisCjd2dzztg7eW4n2aWd/1Ln0=")]
  [s.wi (aB 6 "liel") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAICM1FxTZk1oV5gEz70x9q6ahbeScWgg2lTKXStAgn3XM") (wgk "4dU8QG6UrGkcRREoiO/LCc2EixlaUMKbbdsjGIrOdg0=") (rWgPeers (peersB ++ ["ika"]))]
  [s.wi (aB 10 "uiharu") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIC6aMRME0BCal6Fn5HhM3HDeFmOf5Ya9jCi2v4vFB5fX") (wgk "/4OTj3kJk0GyAKXncjuNGjJmIfZhClf2fRiuWN3IUEM=") (rWgPeers peersB)]
  [s.wi (aB 11 "keiko") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIBVD38g8sHkB1uacAGul7RI/0C4tAmHZOfxAr4ignuUM") (wgk "hBmaJ1WKqdq0PaxeiIrfd+Wzkfk+revkXc7bqWvie2I=")]
  [s.wi (aB null "nova")]
  [s.wi (aB 70 "jibril") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAICfg4VA93VLZAiO+ObZxUEDU8nf089bdI/QMPAeCIjno") (wgk "J3+rkgp9k0bgydu/S1g+UKmg3gkdaS2m86Saajrh+R8=") (rWgPeers peersB)]
  [s.wi (aB 65 "yalda") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIP5W68IOU9/E5wcKML27gd5Z3JpmX5nHAeNX8iiNBG1g") (wgk "jZeP7ghMubj37qm4TbmA6BeJghty89OFvhWkklA19HA=") (rWgPeers peersB)]
  [s.wi (aB null "rune") (aSSHed  "AAAAC3NzaC1lZDI1NTE5AAAAILLzM89Ec/M3/jod75DuPVmeZimXEHiSjM+NpKUnsl/p")]

  # global
  [s.g (aB 1 "ika") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIOGY7dn1FVGVibtkYwIE+g87mTRG1XE7C8jhAe3mARTv") (wgk "jF4eHAXVdis4fYsYeGTwFquaKDvMh8e5pBYAhUiHXiA=") (aNames [ "ika.r.sh.s" "24.199.109.57"]) (aAddrG "24.199.109.57") (rWgPeers (peersB ++ ["keiko" "liel"]))]
])
