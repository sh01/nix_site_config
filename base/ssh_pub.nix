let
 HN = s: [s] ++ [(s + ".sh.s.") (s + ".sh.s") (s + ".vpn.sh.s.") (s + ".vpn.sh.s")];
in rec {
  sh_allison = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDP2ErHhg1qHz/tsfoqjf9Z1TutbVWxPozW7kgOafrX3 sh@allison.sh.s.";
  sh_yalda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUoptwFK1lhRNiR978NN/95ZUre1Xe9GY6XSyursx7s sh@yalda.sh.s.";

  kokoro = {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICdTEAJL0W3GwbSqby9UA5WkmGy/U7cmFvgMmAInj+p sh@kokoro";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBklpUEs9lcmLxMlwQ6cQk0Fn6+F83D76g7dN4jEQgNN root@kokoro";
  };

  root_keiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITxN4NuMIY4hiYgZXpFRILKorw8Nxm95Qu1Ot6BccSn root@keiko.sh.s.";

  hk_allison = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGE+YvDLKwJ9SEm4NgYOELl0TWomv3fGSA7fwLjDWI9I";
  hk_keiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfKZyUyxTT6W6IpdNRPq8ztPJrR/KGDd8I9Wnj+ZShH";
  hk_uiharu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLN1lfEixR0e6XLycRC2FWIVmPtcLcdMj3SxnNWj275";
  hk_yalda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgLnDEu6YIP047/9YvtaJIqh8fjwgCZxDpRAj0jAJD+";
  hk_rune = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6SOWmjQs46p8DI8mwBCSWt7Gi2KwXYrtbTkvknTXnV";

  hk_bw0 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJtyFexV2+utU0Y0EYuJoxgfNKUcOqQ7yCx0QgKhEfbdmBB2U/usZ0gIoTT0pxoqbPOuqk1YYza7BwxM6AJs7hGcuMmRzsqSU9eG9Ow8JT7NyhdLUKes37U+6EA1vea2JmNsvmGvzsmRVB3/tDGpsoSgJhWsKK2Mboc1n6g5UAC+8GHDn329N6nQ7u/wucwC6vFEZa/T2Fppu79eKgjxpyDRO1iWHiEE8pO8mbFWQfrvoKcoyIWbjdh/6s9sARrZ1w15j90OFDOpPMKxIIOff5CIiiwQERdmRL/QNtZOkOCoEUUgU2byKNASoieC8w0voh6OUOtgoecjWsLTiNXJ5Z";
  

  knownHosts = [
    { hostNames = HN "allison"; publicKey = hk_allison;}
    { hostNames = HN "keiko"; publicKey = hk_keiko;}
    { hostNames = HN "uiharu"; publicKey = hk_uiharu;}
    { hostNames = HN "yalda"; publicKey = hk_yalda;}
    { hostNames = HN "rune"; publicKey = hk_rune;}
    { hostNames = ["bw0" "bw0.ulwired-ctl.s."]; publicKey = hk_bw0;}
  ];
}
