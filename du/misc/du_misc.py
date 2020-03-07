#!/usr/bin/env python

import os
import sys
import argparse
import subprocess

ap = argparse.ArgumentParser()

# Add the arguments to the parser
ap.add_argument("--rootdir", action='store', help="root directory")
ap.add_argument("--maxdepth", action='store', help="max-depth value")

args = vars(ap.parse_args())
maxdepth = '-maxdepth'+ ' ' + args['maxdepth'] if args['maxdepth'] else ' '
rootdir = args['rootdir']

proc = subprocess.Popen('find' + ' ' + rootdir + ' ' + maxdepth + ' ' + '-type' + ' ' +  'f', shell=True, stdout=subprocess.PIPE).stdout.readlines()
for i in proc:
  i = i.strip()
  modtime = subprocess.Popen('stat' + ' ' + '-c' + ' ' + '%y' + ' ' +  i, shell=True, stdout=subprocess.PIPE).stdout.readlines()
  disk_space = subprocess.Popen('stat' + ' ' + '-c' + ' ' + '%s' + ' ' +  i, shell=True, stdout=subprocess.PIPE).stdout.readlines()
  print '%s %s %s ' %(i+'[file name]',  disk_space[0].strip()+'[disk used]', str(modtime)+'[modification time]')


print "----------------------------------------------------------------"
print "                Total disk space used by " + rootdir
print "----------------------------------------------------------------"
total_du = subprocess.Popen('du' + ' ' + '-B1' + ' ' + rootdir, shell=True, stdout=subprocess.PIPE).stdout.readlines()
print total_du.pop()
