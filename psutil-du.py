import os
import sys
import psutil
import subprocess
import datetime
import time

def main():
    running = True
    while running:
        try:
            time.sleep(1)
            stats = psutil.cpu_percent(percpu=True)
            mem = psutil.virtual_memory()
            disk = psutil.disk_usage('/root/check_ui.py')
            timestamp = datetime.datetime.now()
            today = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d')
            print stats, mem, disk, timestamp, today

        except Exception as e:
            print(e)
            running = False

#main()
proc = subprocess.Popen('find . -type f', shell=True, stdout=subprocess.PIPE).stdout.readlines()
print proc.pop()
