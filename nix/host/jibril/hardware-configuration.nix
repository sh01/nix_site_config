{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  hardware.cpu.intel.updateMicrocode = true;
  swapDevices = [];
  nix.settings.max-jobs = 12;
  hardware.pulseaudio.extraConfig = ''
load-module module-alsa-card        device_id="1" namereg_fail=false tsched=yes fixed_latency_range=no ignore_dB=no deferred_volume=yes use_ucm=yes avoid_resampling=no
load-module module-alsa-card        device_id="0" namereg_fail=false tsched=yes fixed_latency_range=no ignore_dB=no deferred_volume=yes use_ucm=yes avoid_resampling=no
load-module module-null-sink        sink_name=auto_null sink_properties='device.description="Dummy Output"'
  '';
}
