{pkgs, SH_scripts, ...}:

pkgs.substituteAllFiles {
  name = "SH_container_udev";
  scripts = [SH_scripts];

  files = ["etc"];
  src = ./c;
}
