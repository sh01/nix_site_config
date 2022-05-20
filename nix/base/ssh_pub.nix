let
 HN = s: [s] ++ [(s + ".sh.s.") (s + ".sh.s") (s + ".vpn.sh.s.") (s + ".vpn.sh.s")];
in rec {
  sh_allison = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDP2ErHhg1qHz/tsfoqjf9Z1TutbVWxPozW7kgOafrX3 sh@allison.sh.s.";

  yalda = {
    # Placeholder values until system update and keygen
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJG516zaBDacLrq8WTy+TJ7cZ65hJD/n9kVxw8u14tey sh@yalda";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGr8SrFisvyBMOPV5spfH5P8PXIF3DrOdvLENUzKPOd root@yalda";
  };

  jibril = {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpNjJO3NLBz37ZV/32tkOCO+TTHctiszdlCBuwJaUuX sh@jibril";
    sophia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAOH97qerZCs1LPWarwCFoZR8a4GlKBJC4WF/+/fYH0 sophia@jibril";
  };
  
  kokoro = {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICdTEAJL0W3GwbSqby9UA5WkmGy/U7cmFvgMmAInj+p sh@kokoro";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBklpUEs9lcmLxMlwQ6cQk0Fn6+F83D76g7dN4jEQgNN root@kokoro";
  };

  rune = {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEKsBJt8b20KgeEGr3D7X1PlGlUPpn9O0AphPyF4fk4 sh@rune";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQkWQOwK6rckcRplpCX2bpk/3NBwLtza6jJfAjGRW7v root@rune";
  };

  root_keiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEL4qDILq50ODZBN5lqF1YK/8bm5TEYnZnsh/fYp9x11 root@keiko.sh.s.";

  hk_allison = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGE+YvDLKwJ9SEm4NgYOELl0TWomv3fGSA7fwLjDWI9I";
  hk_keiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVD38g8sHkB1uacAGul7RI/0C4tAmHZOfxAr4ignuUM";
  hk_uiharu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLN1lfEixR0e6XLycRC2FWIVmPtcLcdMj3SxnNWj275";
  hk_yalda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5W68IOU9/E5wcKML27gd5Z3JpmX5nHAeNX8iiNBG1g";
  hk_rune = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLzM89Ec/M3/jod75DuPVmeZimXEHiSjM+NpKUnsl/p";
  hk_ika = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGY7dn1FVGVibtkYwIE+g87mTRG1XE7C8jhAe3mARTv";

  hk_bw0 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJtyFexV2+utU0Y0EYuJoxgfNKUcOqQ7yCx0QgKhEfbdmBB2U/usZ0gIoTT0pxoqbPOuqk1YYza7BwxM6AJs7hGcuMmRzsqSU9eG9Ow8JT7NyhdLUKes37U+6EA1vea2JmNsvmGvzsmRVB3/tDGpsoSgJhWsKK2Mboc1n6g5UAC+8GHDn329N6nQ7u/wucwC6vFEZa/T2Fppu79eKgjxpyDRO1iWHiEE8pO8mbFWQfrvoKcoyIWbjdh/6s9sARrZ1w15j90OFDOpPMKxIIOff5CIiiwQERdmRL/QNtZOkOCoEUUgU2byKNASoieC8w0voh6OUOtgoecjWsLTiNXJ5Z";
  
  knownHosts = {
    allison = { hostNames = HN "allison"; publicKey = hk_allison;};
    keiko = { hostNames = HN "keiko"; publicKey = hk_keiko;};
    uiharu = { hostNames = HN "uiharu"; publicKey = hk_uiharu;};
    yalda = { hostNames = HN "yalda"; publicKey = hk_yalda;};
    rune = { hostNames = HN "rune"; publicKey = hk_rune;};
    ika = { hostNames = [ "ika.r.sh.s" "138.68.246.52"]; publicKey = hk_ika;};
    bw0 = { hostNames = ["bw0" "bw0.ulwired-ctl.s."]; publicKey = hk_bw0;};
  };
}
