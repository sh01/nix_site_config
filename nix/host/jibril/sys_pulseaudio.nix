{
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    systemWide = true;
    #tcp.enable = true;
    extraConfig = "load-module module-native-protocol-unix socket=/run/users/sh_x/pulse/native";
  };
}
