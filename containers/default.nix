let
  bbMounts = {
    "/tmp/.X11-unix" = {
      hostPath = "/tmp/.X11-unix";
      isReadOnly = true;
    };
  };
    "/run/users" = {
      hostPath = "/run/users";
      isReadOnly = true;
  };
in {
  c = rk: uk: {
    browsers = {
      config = ((import ./browsers.nix) rk uk);
      autoStart = true;
      bindMounts = {
        "/home/sh_cbrowser" = {
          hostPath = "/home/sh_cbrowser";
          isReadOnly = false;
        };
      } // bbMounts;
      privateNetwork = true;
      hostAddress = "10.231.1.1";
      localAddress = "10.231.1.2";
    };
  };
}
