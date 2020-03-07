# du tool using stat
The disk usage is found using "stat" utility.
Stat and Find are the utilities which are being used in this script.

## Features
* Display disk space used in byte readable format
* Display modification time along with disk usage
* Display max depth
* Display subtotal or summary of the file system

## Try below commands
./du_misc.py --rootdir=/etc --maxdepth=2

## Usage
usage: du_misc.py [-h] [--rootdir ROOTDIR] [--maxdepth MAXDEPTH]

optional arguments:
  -h, --help           show this help message and exit
  --rootdir ROOTDIR    root directory
  --maxdepth MAXDEPTH  max-depth value
