{config, ...}: {
   # Make sure we don't accidentally retrieve to-be-executed code through insufficiently authenticated channels
   config.system.defaultChannel = "file:///var/local/nix/c0";
}

