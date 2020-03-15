import os

path = "/root"

for (path, dirs, files) in os.walk(path):
    print path
    print dirs
    print files
    print "----"
