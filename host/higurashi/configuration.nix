# Higurashi is an emergency recovery/setup environment.
{ config, pkgs, lib, ... }: let
  slib = import ../../lib;
  vars = import ../../base/vars.nix;
in {
  imports = [ ./base.nix ];
  networking = {
    hostName = "higurashi";
    hostId = "85d5fcc6";
  };

  powerManagement.cpuFreqGovernor = "ondemand";
  
  services = {
    openssh.enable = false;
    mingetty.autologinUser = "root";
  };

  ### User / Group config
  # Define paired user/group accounts.
  # Manually provided passwords are hashed empty strings.
  users = (slib.mkUserGroups ((vars.userSpecs {}).default ++ [
  ])) // {
    users = {
      root.hashedPassword = "$6$FBbDnoKGw3Z1.OO$/x8d4WXCSKLFt0w1CP/ladkGrZHMxvkWCzdz65iaJ7svUh4oEwB44xezqUPNYpKGzpLeisKqOVBuadjl9Bl.7/";
      sh = {
        hashedPassword = "$6$FBbDnoKGw3Z1.OO$/x8d4WXCSKLFt0w1CP/ladkGrZHMxvkWCzdz65iaJ7svUh4oEwB44xezqUPNYpKGzpLeisKqOVBuadjl9Bl.7/";
        shell = "/run/current-system/sw/bin/zsh";
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;
  security.pam.services = {
    login.allowNullPassword = true;
    kdm.allowNullPassword = true;
    su.allowNullPassword = true;
  };
}
