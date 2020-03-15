import time
import sys
import subprocess
import psutil
import datetime

print "This is the name of the script: ", sys.argv[0]
print "Number of arguments: ", len(sys.argv)
print "The arguments are: " , str(sys.argv)

toolbar_width = 100
# setup toolbar
sys.stdout.write("[%s]" % (" " * toolbar_width))
sys.stdout.flush()
sys.stdout.write("\b" * (toolbar_width+1)) # return to start of line, after '['
args = str(sys.argv)

for i in xrange(toolbar_width):
    time.sleep(0.05)
    stats = psutil.cpu_percent(percpu=True)
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    timestamp = datetime.datetime.now()
    today = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d')
    print stats, mem, disk, timestamp, today
    sys.stdout.write("-")
    sys.stdout.flush()

sys.stdout.write("]\n") # this ends the progress bar
