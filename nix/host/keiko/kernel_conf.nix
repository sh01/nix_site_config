{lib, ...}:
let
  vars = import ../../base/vars.nix {inherit lib;};
  ko = vars.kernelOpts;
in with ko; with (import <nixpkgs/lib/kernel.nix> {lib = null;}); base // netStd // termHwStd // termVideo // blkStd // blkMultipath // usbStd // devFreq // x86Std // {
IRQ_TIME_ACCOUNTING = yes;
MODULE_FORCE_LOAD = yes;
}
