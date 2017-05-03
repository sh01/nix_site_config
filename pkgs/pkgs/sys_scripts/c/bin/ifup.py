#!@python2@/bin/python

class IFace:
  address = None
  netmask = None
  default_gateway = None
  def __init__(self, name):
    self.name = name

  def is_complete(self):
    return bool(self.name and self.address and self.netmask)

  def __repr__(self):
    return '{}<**{}>'.format(type(self).__name__, self.__dict__)
  
  def setup(self):
    import subprocess
    cmds = [
      ('ip', 'link', 'set', self.name, 'up'),
      ('ip', 'addr', 'add', '{}/{}'.format(self.address, self.netmask), 'dev', self.name)
    ]
    if self.default_gateway:
      cmds.append(('ip', 'route', 'add', 'default', 'via', self.default_gateway))
    for argv in cmds:
      print('Executing: {}'.format(argv))
      subprocess.call(argv)

def read_interfaces(f):
  ifaces = []
  nameservers = []
  i = None
  for line in f:
    line = line.strip()
    if line.startswith('#'):
      continue
    fields = line.split()
    if len(fields) == 0:
      continue
    cmd = fields[0]
    if (cmd == 'auto'):
      continue
    if len(fields) < 2:
      continue
    if (cmd == 'iface'):
      name = fields[1]
      if (name == 'lo'):
        continue
      i = IFace(name)
      ifaces.append(i)
      continue
    if (i is None):
      continue
  
    if (cmd == 'address'):
      i.address = fields[1]
    elif (cmd == 'netmask'):
      i.netmask = fields[1]
    elif (cmd == 'gateway'):
      i.default_gateway = fields[1]
    elif (cmd == 'dns-nameservers'):
      nameservers.extend(fields[1:])

  return (ifaces, nameservers)

def update_resolvconf(ns):
  import subprocess
  if len(ns) < 1:
    return
  conf = ''.join(['nameserver {}\n'.format(addr) for addr in ns])
  argv = ('resolvconf', '-m1', '-a', 'ifup_py')
  print('Invoking: {} < {!r}'.format(argv, conf))
  p = subprocess.Popen(argv, stdin=subprocess.PIPE)
  p.stdin.write(conf)
  p.stdin.close()
  p.wait()


def main():
  import sys
  fn = sys.argv[1]
  f = open(fn, 'rb')
  (ifaces, ns) = read_interfaces(f)
  print ifaces, ns
  for iface in ifaces:
    if iface.is_complete():
      iface.setup()

  update_resolvconf(ns)


if __name__ == '__main__':
  main()
