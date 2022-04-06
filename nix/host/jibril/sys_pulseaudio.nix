{
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    systemWide = true;
    #tcp.enable = true;
    daemon.config = {
      # Nix defaults
      "flat-volumes" = "no";
      "resample-method" = "speex-float-5";
      # Disable runtime module-loading to reduce shared-user attack surface.
      "allow-module-loading" = "no";
    };
  };
}
