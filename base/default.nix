{
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };
  environment.shellAliases = {
    ne = "PAGER=cat nix-env";
  };
}
