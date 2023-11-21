{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.extraModulePackages = [ ];
  swapDevices = [];
  nix.settings.max-jobs = 8;
  nix.nrBuildUsers = 16;
}
