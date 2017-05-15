#!@python3@/bin/python3

import re

### Config things
patterns = {
}

def add_pattern(disk, off, length, hash, desc=None):
  hash = str(hash)
  if (len(hash) != 128):
    raise ValueError('Invalid checksum {!r} (length {}) for {!r}.'.format(hash, len(hash), disk))

  if (desc is None):
    desc = disk
  patterns.setdefault(bytes(disk),[]).append((int(off), int(length), hash, desc))

for (disk, specs) in (
# Add patterns here.
(b'ata-ST9320423AS_5VJE6NHK', [(0, 134217728, 'd27d1ae0b261095afc966d3eed22ea63e22bb3c4c7488e4e831fd9f888b52d72fbb1a586ff25200595b5bf3deb57b250d033a5d1b1503fbd13876f6e983d171a', 'rune hdd')]),
(b'ata-ST1000LM024_HN-M101MBB_S2R8J9DCB00592', [(0, 1075838464, '781573f5fc6cef6b208fe874546820afd9dfd997eb0bde616ed8ef542b88ca85bd6927f65f474090d7652a0907b1a6f3b815b99cbfe12edb33d53de37f1dac07', 'likol hdd')]),
(b'wwn-0x500a0751031b826f', [(0, 1024**3, '60d05c6caac3c04ee7ef85d180ade1d135889596ef839469e267d36bb2b7c5697a7cb421ced9696bcdbd0c35af3942593273cdcd19d0050f902b177ea0c1e578', 'likol ssd')]),
  ):
  for spec in specs:
    add_pattern(disk, *spec)


C_RESET = '\x1b[0m'
C_RED = '\x1b[1;31m'
C_GREEN = '\x1b[1;32m'
C_YELLOW = '\x1b[1;33m'

def c_color(color):
  def c(s):
    return '{}{}{}'.format(color, s, C_RESET)
  return c

c_red = c_color(C_RED)
c_green = c_color(C_GREEN)
c_yellow = c_color(C_YELLOW)

class DiskInfo:
  def __init__(self, name):
    self.name = name.decode('latin-1')
    self.check_num = 0

### Implementation
class HashChecker:
  NODE_NAME_DISK_RE = re.compile(b'^[sh]d[a-z]+$')
  def __init__(self):
    self.n_ok = 0
    self.n_fail = 0
    self.disks = {}

  def check_dir(self, base_path):
    from os import listdir, readlink
    from os.path import join, basename
    from hashlib import sha512 as H
    
    names = listdir(base_path)
    names.sort()

    for name in names:
      p = join(base_path, name)
      specs = patterns.get(name, ())
      try:
        dst_name = readlink(p)
      except OSError:
        pass
      else:
        dst_name = basename(dst_name)
        if self.NODE_NAME_DISK_RE.match(dst_name):
          di = self.disks.setdefault(dst_name, DiskInfo(name))
          di.check_num += len(specs)

      for (off, length, hd_want, desc) in specs:
        f = open(p, 'rb')
        f.seek(off)
        h = H()
        while (length > 0):
          rl = min(length, 16777216)
          data = f.read(rl)
          if (len(data) == 0):
            break
          h.update(data)
          length -= len(data)
        hd_have = h.hexdigest()

        if (hd_have == hd_want):
          self.n_ok += 1
          print('{} {}: {}'.format(desc, c_green('OK'), hd_have), flush=True)
        else:
          self.n_fail += 1
          print('{} {}:'.format(desc, c_red('FAIL')), flush=True)
          for (x,y) in ((0,64), (64,128)):
            ws = hd_want[x:y]
            print(c_yellow(ws), flush=True)
            hs = hd_have[x:y]
            print(c_red(hs), flush=True)

  def print_summary(self):
    untested_disks = []
    for disk in self.disks.values():
      if (disk.check_num == 0):
        untested_disks.append(disk.name)
    untested_disks.sort()
    ud_str = ', '.join(untested_disks)

    print('==== Summary:\nUntested: {}\nChecks: {} OK // {} FAIL // {} UNTESTED'.format(ud_str, c_green(self.n_ok), c_red(self.n_fail), c_yellow(len(untested_disks))))


def main():
  import sys
  hc = HashChecker()
  hc.check_dir(b'/dev/disk/by-id')
  hc.print_summary()

  sys.stdout.flush()
  sys.stderr.flush()

  from time import sleep
  while True:
    sleep(3600)

if __name__ == '__main__':
  main()
