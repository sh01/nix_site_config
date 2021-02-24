# Stash some scripts that should be invoked from configuration in particular
# home directories (as after X loging of specific users).
# By keeping them in a nix package, we can use static reference paths inside
# the home-dir confs and update the actual scripts along with the rest of the
# system.

{pkgs, ...}:
pkgs.substituteAllFiles {
  name = "SH_scripts";
  bash = pkgs.bash;
  python3 = pkgs.python3;
  iproute2 = pkgs.iproute;

  src = ./s;
  files = ["share"];
  postInstall = "chmod a+x $out/share/local/bin/*";
}
