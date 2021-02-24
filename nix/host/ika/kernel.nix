let
  vars = (import ../../base/vars.nix);
  kp = vars.kernelPatches;
  ko = vars.kernelOpts;
in
{
  #### Kernel config
  powerManagement.cpuFreqGovernor = "powersave";
  nixpkgs.config.packageOverrides = p: {
    stdenv = p.stdenv // {
      platform = p.stdenv.platform // {
        kernelPatches = p.linux.kernelPatches ++ kp;
        kernelExtraConfig = with ko; base;
        ignoreConfigErrors = true;
      };
    };
  };
}
