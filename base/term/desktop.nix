{pkgs, ...}: {
  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    sys_terminal_wired
  ];
  imports = [
    ./base.nix
  ];
}
