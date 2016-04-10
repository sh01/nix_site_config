#!@python3@/bin/python3

import json
import curses

class Menu:
  def __init__(self, entries):
    self.entries = entries
    self.idx = 0
    self.done = False

  def show_menu(self, scr):
    scr.clear()
    scr.addstr(0, 0, "JSON NixOS boot menu:")
    ym_base = 1

    for l, e in enumerate(self.entries):
      if (l == self.idx):
        a = (curses.A_REVERSE,)
      else:
        a = ()
      scr.addstr(ym_base + l, 2, '{}: {}'.format(l, e['title']), *a)
    scr.refresh()

  def update(self, scr):
    k = scr.getkey()
    if (k == 'KEY_DOWN'):
      if self.idx < len(self.entries)-1:
        self.idx += 1
      return
    if (k == 'KEY_UP'):
      if self.idx > 0:
        self.idx -= 1
      return
    if (k == '\n'):
      self.done = True
      return

    try:
      v = int(k)
    except ValueError:
      pass
    else:
      if v < len(self.entries):
        self.idx = v
      return
    
  def show(self, scr):
    curses.curs_set(False)
    while (not self.done):
      self.show_menu(scr)
      self.update(scr)

def boot(entry):
  from os import execl, environb
  sc = entry['systemConfig'].encode('ascii')
  init = entry['init'].encode('ascii')

  environb[b'systemConfig'] = sc
  print(init)
  execl(init, init)
  

def main():
  import sys
  if len(sys.argv) > 1:
    fn = sys.argv[1]
  else:
    fn = "/boot/nix.json"

  f = open(fn, 'r')
  entries = json.load(f)
  f.close()
  m = Menu(entries)
  curses.wrapper(m.show)

  boot_entry = entries[m.idx]
  print('Booting: {}'.format(boot_entry))
  boot(boot_entry)

if __name__ == '__main__':
  main()
