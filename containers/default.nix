{
  c = rk: uk: {
    browsers = {
      config = ((import ./browsers.nix) rk uk);
      autoStart = true;
      bindMounts = {
        "/home/sh_browsers" = {
          hostPath = "/home/sh_browsers";
          isReadOnly = false;
        };
      };
    privateNetwork = true;
    };
  };
}
