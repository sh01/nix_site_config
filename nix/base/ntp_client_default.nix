{...}: {
  services.ntp = {
    enable = true;
    servers = ["10.17.1.1"];
  };
}
