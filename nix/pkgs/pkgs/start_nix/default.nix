{ pkgs, ...}:

pkgs.substituteAll {
  name = "start_nix";
  dir = "bin";
  src = ./start_nix.py;
  isExecutable = true;
  python3 = [pkgs.python3];
}
