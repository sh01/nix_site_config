{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [];
  boot.extraModulePackages = [ ];
  hardware.cpu.intel.updateMicrocode = true;

  swapDevices = [];
  nix.maxJobs = 2;
}
