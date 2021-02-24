#!@python@/bin/python

from os import environ
from sys import argv, exit

def mkaddr(a, b=None):
  lines = []
  if not (a is None):
    lines.append('ifconfig-push {} @gateway4@\n'.format(a))
  if not (b is None):
    lines.append('ifconfig-ipv6-push {}/64 @gateway6@\n'.format(b))
  return ''.join(lines)

clients = {
@client_config@
}

out = open(argv[1], 'r+')
out.seek(0)
out.truncate()
CN = environ.get('common_name')

conf = clients.get(CN)
if (conf is None):
  print('Unknown CN {!r}.'.format(CN))
  exit(1)

print('Mapping: {!r} -> {!r}'.format(CN, conf))
out.write(conf)
out.close()
exit(0)
