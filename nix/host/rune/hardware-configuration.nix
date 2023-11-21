{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  #hardware.enableAllFirmware = true;
  #hardware.cpu.intel.updateMicrocode = true;

  boot.extraModulePackages = [ ];
  swapDevices = [];
  nix.settings.max-jobs = 4;
  nix.nrBuildUsers = 16;
}
