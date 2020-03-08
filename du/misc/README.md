# du tool using stat
* The disk usage is calculated using "stat" and "Find" utilities. This is just another way to calculate disk usage.
* The disk usage is calculated on per file basis. Each file is put in a loop and "stat" command is run on the file to get disk usage, and modification time
* The max depth is input to find command itself

## Features
* Display disk space used in byte readable format
* Display modification time along with disk usage
* Display max depth
* Display subtotal or summary of the file system

## Try below commands
./du_misc.py --rootdir=/etc --maxdepth=2

## Usage
usage: du_misc.py [-h] [--rootdir ROOTDIR] [--maxdepth MAXDEPTH]\

optional arguments:\
  -h, --help           show this help message and exit\
  --rootdir ROOTDIR    root directory\
  --maxdepth MAXDEPTH  max-depth value
