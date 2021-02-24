{ pkgs, ...}:

pkgs.substituteAll {
  name = "blk_chk";
  dir = "bin";
  src = ./blk_chk.py;
  isExecutable = true;
  python3 = [pkgs.python3];
}
