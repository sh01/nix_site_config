{
  imports = [ ./base.nix ];
  networking = {
    hostName = "aswinhaa";
    hostId = "85d5fcc7";
  };
  services.openssh.enable = true;
  services.openssh.moduliFile = ./sshd_moduli;
}
