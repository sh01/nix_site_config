{lib, ...}:
let
  inherit (lib) mkForce;
  uid = 140;
in {
  # Grabbed from ./nixos/modules/config/pulseaudio.nix, modified to fix uid and gid.
  users = {
    users.pulse = {
      uid = mkForce uid;
      group = "pulse";
      extraGroups = [ "audio" ];
      home = "/run/pulse";
      createHome = mkForce false;
      isSystemUser = true;
    };
    groups.pulse.gid = mkForce uid;
  };
}
