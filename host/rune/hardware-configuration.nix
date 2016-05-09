{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.extraModulePackages = [ ];
  swapDevices = [];
  nix.maxJobs = 4;
  nix.nrBuildUsers = 16;
}
