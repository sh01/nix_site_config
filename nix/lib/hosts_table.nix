# Declarative host data shared with all hosts for inter-host communication.
{lib, l, ...}: let
  inherit (builtins) foldl';
  sites = import ../base/sites.nix {inherit lib;};

  HN = s: [s "${s}.sh.s." "${s}.sh.s" "${s}.vpn.sh.s." "${s}.vpn.sh.s"];
  hostRecord = {hn, idx, hk_ssh ? "ssh-ed25519 _NOKEY", hk_wg ? null, site_name ? null, names ? HN hn, addr_global ? null}: {
    "${hn}" = rec {
      inherit idx names;
      pub = {
        ssh = hk_ssh;
        wireguard = hk_wg;
      };

      site = if (site_name == null) then null else sites."${site_name}";
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

  s = {
    wi = aSite "wi";
    g = aSite "global";
  };

  wgk = k: {
    hk_wg = k;
  };

in (foldl' (l: row: let
  args = foldl' (a: b: a // b) {} row;
  hrec = hostRecord args;
in (l // hrec)) {} [
  # wi
  [s.wi (aB 1 "bw0") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAICM1FxTZk1oV5gEz70x9q6ahbeScWgg2lTKXStAgn3XM") (aNames ["bw0" "bw0.ulwired-ctl.s."])]
  [s.wi (aB null "allison") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIGE+YvDLKwJ9SEm4NgYOELl0TWomv3fGSA7fwLjDWI9I")]
  [s.wi (aB 6 "liel") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAICM1FxTZk1oV5gEz70x9q6ahbeScWgg2lTKXStAgn3XM") (wgk "4dU8QG6UrGkcRREoiO/LCc2EixlaUMKbbdsjGIrOdg0=")]
  [s.wi (aB 10 "uiharu") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIC6aMRME0BCal6Fn5HhM3HDeFmOf5Ya9jCi2v4vFB5fX") (wgk "/4OTj3kJk0GyAKXncjuNGjJmIfZhClf2fRiuWN3IUEM=")]
  [s.wi (aB 11 "keiko") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIBVD38g8sHkB1uacAGul7RI/0C4tAmHZOfxAr4ignuUM")]
  [s.wi (aB null "nova")]
  [s.wi (aB null "jibril")]
  [s.wi (aB null "yalda") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIP5W68IOU9/E5wcKML27gd5Z3JpmX5nHAeNX8iiNBG1g")]
  [s.wi (aB null "rune") (aSSHed  "AAAAC3NzaC1lZDI1NTE5AAAAILLzM89Ec/M3/jod75DuPVmeZimXEHiSjM+NpKUnsl/p")]

  # global
  [s.g (aB 1 "ika") (aSSHed "AAAAC3NzaC1lZDI1NTE5AAAAIOGY7dn1FVGVibtkYwIE+g87mTRG1XE7C8jhAe3mARTv") (wgk "jF4eHAXVdis4fYsYeGTwFquaKDvMh8e5pBYAhUiHXiA=") (aNames [ "ika.r.sh.s" "24.199.109.57"]) (aAddrG "24.199.109.57")]
])
