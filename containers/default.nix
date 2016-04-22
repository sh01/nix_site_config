{
  c = {
    browsers = {
      config = (import ./browsers.nix);
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
