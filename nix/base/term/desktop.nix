{pkgs, l, ...}: {
  ### System profile packages
  environment.systemPackages = with (pkgs.callPackage ../../pkgs/pkgs/meta {}); [
    sys_terminal_wired
  ];
  imports = [(l.call ./base.nix)];
}
