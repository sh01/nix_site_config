let
  pkgs = import <nixpkgs> {};
in with pkgs.lib; rec {
  mkGroups = specs: mkMerge ((map (s:
    let U = elemAt s 0;
    in { "${U}" = {
      name = U;
      gid = (elemAt s 1);
    }; }) specs) ++ [{
      "nix-users" = { gid = 2049; };
    }]);
   
  mkUsers = specs: mkMerge (map (s:
    let U = elemAt s 0;
    in { "${U}" = {
      name = U;
      uid = (elemAt s 1);
      group = U;
      extraGroups = (elemAt s 2);
      openssh.authorizedKeys.keys = (elemAt s 3);
      isNormalUser = true;
    };
  }) specs);

  mkUserGroups = specs: {
    users = mkUsers specs;
    groups = mkGroups specs;
  };
}
