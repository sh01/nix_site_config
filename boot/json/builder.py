#!@python3@/bin/python3

import os
import sys
import time


class BootEntries:
  def __init__(self):
    self.entries = []

  @staticmethod
  def fmt_time(ts):
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(ts))
    
  def read_profiles(self, p):
    from glob import glob
    for d in glob(p):
      (_, fn) = d.rsplit(b'/', 1)
      (_, gen, _) = fn.split(b'-')
      gen = int(gen)
      self.add_profile(d, gen)

  def add_profile(self, d, gen, ts=None):
    try:
      d_dref = os.readlink(d)
    except OSError:
      d_dref = d

    kdir = os.readlink(os.path.join(d, b'kernel'))
    (_, hd, _) = kdir.rsplit(b'/', 2)
    (_, kver) = hd.rsplit(b'-', 1)
    kstat = os.lstat(d)
    if (ts is None):
      ts = kstat.st_mtime
    title = 'NixOS %d (linux-%s) %s' % (gen, kver.decode('ascii'), self.fmt_time(ts))

    self.entries.append((gen, ts, title, d_dref))

  def sort(self):
    self.entries.sort()

  def print_entries(self):
    print('Json boot menu entries:')
    for entry in self.entries:
      print('  ', entry)
  
  def write_json(self, out):
    import json
    et = []
    for (gen, mtime, title, _dir) in self.entries:
      init = os.path.join(_dir.decode('ascii'), 'init')
      et.append({'gen':gen, 'mtime':mtime, 'title':title, 'init': init, 'systemConfig': _dir.decode('ascii')})
    json.dump(et, out)


def main():
  import tempfile
  
  be = BootEntries()
  be.read_profiles(b'/nix/var/nix/profiles/system-*-link')
  if (len(sys.argv) > 1):
    default_path = sys.argv[1].encode('ascii')
    be.add_profile(default_path, -1, time.time())
  be.sort()
  be.print_entries()
  
  dst_fn = '@out_filename@'
  print('Writing JSON boot data to {!r}.'.format(dst_fn))
  tf = tempfile.NamedTemporaryFile(mode='w', encoding='ascii', delete=False)
  be.write_json(tf)
  os.rename(tf.name, dst_fn)

if __name__ == '__main__':
  main()
