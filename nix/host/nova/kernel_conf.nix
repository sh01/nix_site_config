{lib, ...}:
let
  inherit (lib) mkForce;
  vars = (import ../../base/vars.nix {inherit lib;});
  ko = vars.kernelOpts;
in with ko; with (import <nixpkgs/lib/kernel.nix> {lib = null;}); base // netStd // termHwStd // termVideo // hwAudio // blkStd // usbStd // devFreq // x86Std // {
DRM_I915 = mkForce yes;
SND_SOC_SOF_HDA = yes;
SND_SOC_SOF_HDA_AUDIO_CODEC = yes;
SND_SOC_SOF_APOLLOLAKE = mkForce yes;
SND_SOC_SOF_INTEL_APL = yes;
HDMI_LPE_AUDIO = yes;
}
