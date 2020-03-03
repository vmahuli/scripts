#!/usr/bin/env python

''' Python disk utility Script to display disk usage of a file system '''
VERSION = '1.0'

import sys
import argparse
import subprocess

# for displaying help
def usage():
  ap.print_help()
  sys.exit(1)

# module to run "tree" command
def show_tree(args):
  rootdir = args['rootdir']
  tree_cmd = 'tree' + ' ' + '-a' + ' ' + '-h' + ' ' + '--du' + ' ' + rootdir
  print
  print 'Executing... ' + tree_cmd
  print
  subprocess.call(tree_cmd, shell=True)

# module to display disk space used
def disk_usage(args):
  humanread = '-h' if args['humanread'] else ' '
  byteread = '-B1' if args['byteread']  else ' '
  maxdepth = '--max-depth='+ args['maxdepth'] if args['maxdepth'] else ' '
  modtime = '--time' if args['modtime'] else ' '
  subtotal = '--summarize' if args['subtotal'] else ' '
  rootdir = args['rootdir']

  try:
    print
    print 'Executing... '
    print
    print 'du' + ' ' + byteread + ' ' + humanread + ' ' + rootdir +' '+ maxdepth + ' ' + modtime + ' ' + subtotal
    print "----------------------------------------------------------------"
    ret = subprocess.call('du' + ' ' + byteread + ' ' + humanread + ' ' + rootdir +' '+ maxdepth + ' ' + modtime + ' ' + subtotal, shell=True)
    print
    if not ret:
      proc = subprocess.Popen('du' + ' ' + byteread + ' ' + humanread + ' ' + rootdir +' '+ maxdepth + ' ' + modtime + ' ' + subtotal, shell=True, stdout=subprocess.PIPE).stdout.readlines()
      if len(proc):
        print "----------------------------------------------------------------"
        print "                Total disk space used"
        print "----------------------------------------------------------------"
        print proc.pop()
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
ap.add_argument("--subtotal", action='store_true', help="subtotal value (optional)")
ap.add_argument("--showtree", action='store_true', help='''Show disk usage in tree format (optional);
                                                           use showtree only with rootdir''')
args = vars(ap.parse_args())

# handle surprises
if args['byteread'] and args['humanread']:
  usage()
if args['rootdir'] is '':
  usage()
if args['showtree'] and args['rootdir'] is None:
  usage()

if args['showtree']:
  show_tree(args)
else:
  disk_usage(args)
