#!@interp@

import struct

def patch_xauth(data, new_host):
  (x0, l) = struct.unpack('>HH',data[:4])
  tail = data[4+l:]
  
  return (struct.pack('>HH', x0, len(new_host)) + new_host + tail)

def main():
  import sys
  new_host = sys.argv[1].encode('utf-8', 'surrogateescape')

  d = sys.stdin.buffer.read()
  sys.stdout.buffer.write(patch_xauth(d, new_host))

if __name__ == '__main__':
  main()
