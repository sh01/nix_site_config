{
  environment.etc = {
    "zshrc.local" = {
      text = (builtins.readFile ./etc/zshrc.local);
    };
  };
}
