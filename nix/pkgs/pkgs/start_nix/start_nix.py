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

    (height, _) = scr.getmaxyx()
    ym_base = 0
    # Only print header if we can spare a line
    if (height > 1):
      scr.addstr(0, 0, "JSON NixOS boot menu:")
      ym_base += 1
    height -= ym_base

    # Pick subrange of menu to display on screen
    if (len(self.entries) > height):
      e_base, idx = divmod(self.idx, height)
      e_base *= height
      line_lim = e_base+height
      entries = self.entries[e_base:line_lim]
    else:
      e_base = 0
      entries = self.entries
      idx = self.idx
    
    for l, e in enumerate(entries):
      if (l == idx):
        a = (curses.A_REVERSE,)
      else:
        a = ()
      try:
        scr.addstr(ym_base + l, 2, '{}: {}'.format(e_base + l, e['title']), *a)
      except curses.error:
        continue
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

  for (k,v) in entry['env'].items():
    environb[k.encode('ascii')] = v.encode('ascii')

  init = entry['init']
  execl(init, init)
  

def main():
  import argparse
  import sys

  p = argparse.ArgumentParser()
  p.add_argument('-j', '--nix_json', default='/boot/nix.json', metavar='PATH')
  args, _ = p.parse_known_args()

  fn = args.nix_json

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
