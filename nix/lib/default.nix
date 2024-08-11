{pkgs, ...}:
with pkgs.lib; rec {
  mkGroups = specs: mkMerge ((map (s:
    let U = elemAt s 0;
    in { "${U}" = {
      name = U;
      gid = (elemAt s 1);
    }; }) specs) ++ [{
      "nix-users".gid = 2049;
      "game_pad".gid = 2010;
      "input_game".gid = 2011;
    }]);

  mkUsers = specs: mkMerge (map (s:
    let U = elemAt s 0;
    in { "${U}" = {
      name = U;
      createHome = false;
      uid = (elemAt s 1);
      group = U;
      extraGroups = (elemAt s 2);
      openssh.authorizedKeys.keys = (elemAt s 3);
      isNormalUser = true;
    } // (elemAt s 4);
  }) specs);

  mkUserGroups = specs: {
    users = mkUsers specs;
    groups = mkGroups specs;
    enforceIdUniqueness = false;
  };

  lpkgs = (pkgs.callPackage ../../pkgs {});
  
  startupScriptC = {name, script}: {
    "SH_${name}" = {
      wantedBy = ["multi-user.target"];
      path = with pkgs; [coreutils eject lvm2 kmod cryptsetup utillinux];
      script = script;
    };
  };
}
