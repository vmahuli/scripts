#!/usr/bin/env python

from configparser import ConfigParser
import sys
import argparse
import subprocess

configur = ConfigParser()
configur.read('config.ini')

#print ("Sections : ", configur.sections())
print (configur.get(sys.argv[1], 'packages'))
