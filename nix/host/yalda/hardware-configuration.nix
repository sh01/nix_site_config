{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  # PG278Q+intel IGP DP auto-config does not work correctly.
  # Making this work using services.xserver.*Section is a pain. Much easier to just drop in a file.
  environment.etc ={
    "X11/xorg.conf.d/998-devices.conf" = {
      text = (builtins.readFile ./998-devices.conf);
    };
    "X11/xorg.conf.d/999-layout.conf" = {
      text = (builtins.readFile ./999-layout.conf);
    };
  };

  boot.extraModulePackages = [];
  swapDevices = [];
}
