import argparse
import subprocess

def disk_usage(args):
  humanread = '-h' if args['humanread'] else ' '
  byteread = '-B1' if args['byteread']  else ' '
  maxdepth = '--max-depth='+ args['maxdepth'] if args['maxdepth'] else ' '
  modtime = '--time' if args['modtime'] else ' '
  rootdir = args['rootdir']

  try:
    subprocess.call('du' + ' ' + byteread + ' ' + humanread + ' ' + rootdir +' '+ maxdepth + ' ' + modtime, shell=True)
  except:
    print 'Please check the args!!!'

# Construct the argument parser
ap = argparse.ArgumentParser()

# Add the arguments to the parser
ap.add_argument("--humanread", action='store_true', help="human readable output (either human readable or byte readable)")
ap.add_argument("--byteread", action='store_true', help="byte readable output (either byte readable or human readable)")
ap.add_argument("--rootdir", action='store', help="root directory (mandatory)")
ap.add_argument("--maxdepth", action='store', help="max-depth value (optional)")
ap.add_argument("--modtime", action='store_true', help="mod time value (optional)")
args = vars(ap.parse_args())

if args['byteread'] and args['humanread']:
  ap.print_help()
if args['rootdir'] is None:
  ap.print_help()
disk_usage(args)
