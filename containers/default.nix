{
  c = rk: uk: {
    browsers = {
      config = ((import ./browsers.nix) rk uk);
      autoStart = true;
      bindMounts = {
        "/home/sh_cbrowser" = {
          hostPath = "/home/sh_cbrowser";
          isReadOnly = false;
        };
      };
    privateNetwork = true;
    };
  };
}
