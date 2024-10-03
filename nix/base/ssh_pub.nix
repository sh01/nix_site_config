let
 HN = s: [s] ++ [(s + ".sh.s.") (s + ".sh.s") (s + ".vpn.sh.s.") (s + ".vpn.sh.s")];
in rec {
  sh_allison = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDP2ErHhg1qHz/tsfoqjf9Z1TutbVWxPozW7kgOafrX3 sh@allison.sh.s.";
  sophia_wot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJumYSqoetISOVw6hyfLdmJGdIBDr72E3WvnBV1Jh45 sophia@wot";

  yalda = rec {
    # Placeholder values until system update and keygen
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJG516zaBDacLrq8WTy+TJ7cZ65hJD/n9kVxw8u14tey sh@yalda";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGr8SrFisvyBMOPV5spfH5P8PXIF3DrOdvLENUzKPOd root@yalda";
    cont_users = [sh];
  };

  jibril = rec {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpNjJO3NLBz37ZV/32tkOCO+TTHctiszdlCBuwJaUuX sh@jibril";
    sophia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAOH97qerZCs1LPWarwCFoZR8a4GlKBJC4WF/+/fYH0 sophia@jibril";
    cont_users = [sh sophia];
  };
  
  kokoro = {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICdTEAJL0W3GwbSqby9UA5WkmGy/U7cmFvgMmAInj+p sh@kokoro";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBklpUEs9lcmLxMlwQ6cQk0Fn6+F83D76g7dN4jEQgNN root@kokoro";
  };

  rune = rec {
    sh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEKsBJt8b20KgeEGr3D7X1PlGlUPpn9O0AphPyF4fk4 sh@rune";
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQkWQOwK6rckcRplpCX2bpk/3NBwLtza6jJfAjGRW7v root@rune";
    cont_users = [sh];
  };

  # ext
  euphorbia = {
    rtanen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFUQX6hAHsnGikM6W6hRki7oI7jSlIvHhWixemheSDK rtanen@euphorbia";
  };
  gungnir = {
    ratheka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLxOZIUn9seDp7mtdIefoLTO9i+cQbkoOWT0Ph2mALh";
  };
  

  root_keiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEL4qDILq50ODZBN5lqF1YK/8bm5TEYnZnsh/fYp9x11 root@keiko.sh.s.";
}
