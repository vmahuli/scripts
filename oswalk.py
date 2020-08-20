import os

path = "/Users/vmahuli/github/scripts"

for (path, dirs, files) in os.walk(path):
    print path
    print dirs
    print files
    print "----"
