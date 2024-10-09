{servers, ...}: {
  services.ntp = {
    enable = true;
    servers = servers;
  };
}
