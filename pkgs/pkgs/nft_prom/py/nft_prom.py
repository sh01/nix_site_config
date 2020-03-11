#!@python3@/bin/python3

import argparse
import json
import re
import subprocess
import sys

from aiohttp import web


def parse_counters(jdc):
  tables = {}
  for it in jdc:
    for (key, v) in it.items():
      if key != 'counter':
        continue
      t = tables.setdefault(v['table'], {})
      t[v['name']] = Counter.build_from_dict(v)
  return tables

class Counter:
  def __init__(self, n_bytes, n_packets):
    self.bytes = n_bytes
    self.packets = n_packets

  @classmethod
  def build_from_dict(cls, d):
    return cls(d['bytes'], d['packets'])

  def __repr__(self):
    return '{}{}'.format(self.__class__.__name__, (self.bytes, self.packets))


class NFT:
  ARGS_BASE = (b'nft', b'-j', b'list')
  TIMEOUT = 32

  def get_counters(self):
    p = subprocess.Popen((self.ARGS_BASE + (b'counters',)), stdout=subprocess.PIPE)
    stdout, stderr = p.communicate(timeout=self.TIMEOUT)
    jd = json.loads(stdout)['nftables']
    return parse_counters(jd)
    
  def get_handler(self):
    async def handle(req):
      para = req.query
      re_s = para['ct_name_fmt']
      re_ = re.compile(re_s)
      
      name = 'nft_ct'
      output = ['# TYPE {} counter\n'.format(name)]
      
      def out(val, label_map):
        labels = []
        for k, v in sorted(label_map.items()):
          labels.append('{}={}'.format(k, json.dumps(v)))

        label_str = '{%s}' % (', '.join(labels))
        output.append('{}{} {:d}\n'.format(name, label_str, val))
      
      for table_name, v in self.get_counters().items():
        for ct_name, ct in v.items():
          m = re_.search(ct_name)
          if m is None:
            continue
          labels = dict(m.groupdict())
          labels['unit'] = 'bytes'
          out(ct.bytes, labels)
          labels['unit'] = 'packets'
          out(ct.packets, labels)
      
      return web.Response(text=''.join(output), content_type='text/plain; version=0.0.4')
    return handle
  
def main():
  ap = argparse.ArgumentParser()
  ap.add_argument('--port', type=int, default=0)
  args = ap.parse_args()

  nft = NFT()
  app = web.Application()
  h = nft.get_handler()
  app.add_routes([
    web.get('/probe', h)
   ])
  # Check NFT is present, functional and compatible.
  nft.get_counters()
  # Run web server.
  web.run_app(app, port=args.port)

if __name__ == '__main__':
  main()

