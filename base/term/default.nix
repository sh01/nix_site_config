{pkgs, ...}: {
  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    sys_terminal
  ];
} // (import ./base.nix {inherit pkgs;})
