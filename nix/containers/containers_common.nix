{...}:
let
  dns = (import ../base/dns.nix) {};
in {
  imports = [
    ../base/sys_pulseaudio_user.nix
  ];
  environment.etc."resolv.conf" = dns.resolvConfCont;
  boot = {
    tmpOnTmpfs = false;
    isContainer = true;
  };

  systemd.mounts = [{
    where = "/tmp";
    enable = false;
  }];

  system.activationScripts = {
    # As of 17.03/2017-07-03, something in Nix really wants to mount a tmpfs
    # on /tmp even given the above settings.
    # We don't want this, both for ram use reasons and because it shadows some
    # bind mounts we put there, so reverse the mount here.
    tmp_root = {
      text = ''
if mountpoint -q /tmp; then
  umount /tmp && chmod 1777 /tmp
fi
'';
      deps = [];
    };
  };
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
    extraConfig = "AcceptEnv DISPLAY";
  };
}

