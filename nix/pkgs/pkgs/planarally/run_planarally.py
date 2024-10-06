#!@@python3@@

# A wrapper script for planarally, to allow running it from the nix store while
# keeping data in separate runtime directories.

from os.path import dirname, join, realpath
import sys

_code_args = ('ascii', 'surrogateescape')

def run_pa():
  """Run planar ally. Same as planarserver.py."""
  from src import planarserver
  return planarserver.main()

def patch_pa_rundir(rundir):
  """Patch sys.executable to redirect planarally src.utils lookups"""
  fake_exe_path = join(rundir, b'__fake_executable_name.py')
  sys.frozen = True
  sys.executable = fake_exe_path.decode(*_code_args)

def patch_python_path():
  """Add planarally code dir to sys.path."""
  from inspect import getfile
  code_dir = join(dirname(realpath(__file__.encode(*_code_args))), b'..', b'pa')
  sys.path.append(code_dir.decode(*_code_args))
  return code_dir


def main():
  from argparse import ArgumentParser
  from os import getcwdb
  from pathlib import Path
  
  ap = ArgumentParser()
  ap.add_argument('--rundir', type=str)
  ap.add_argument('--test', action='store_true')
  ap.add_argument('pargs', nargs='*')
  ns = ap.parse_args()
  if (ns.rundir):
    rundir = ns.rundir.encode(*_code_args)
  else:
    rundir = getcwdb()
  
  code_dir = patch_python_path()
  print(f'Planarally code dir: {code_dir:}')
  
  patch_pa_rundir(rundir)

  import src.utils
  src.utils.STATIC_DIR = Path(join(code_dir, b"static").decode(*_code_args))

  from src.utils import FILE_DIR
  print(f'Running planarally on FILE_DIR: {FILE_DIR:}')

  if (not ns.test):
    sys.argv[1:] = ns.pargs
    return run_pa()

if (__name__ == '__main__'):
  main()
