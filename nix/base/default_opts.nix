{lib, ...}: {
  options.l = {
    ext_ports_t = lib.mkOption {
      type = with lib.types; listOf (str);
      default = [];
      description = "local SH config: List of port ranges to accept external TCP connections to.";
    };
  };
}
