# Readme for du utility

## This utility...
* Is supported on centos, redhat and ubuntu hosts.
* Supports only python2
* Does most of the work which du command does, just that it is written in python

## Features
* Display disk space used in human readable format and byte readable format
* Display modification time along with disk usage
* Display max depth
* Display subtotal or summary of the file system
* Display disk usage in tree format which is human readable

## Use below steps to install

* ./setup.sh (installs required softwares and modules)
* ./du.py --byteread --rootdir=/etc/ --maxdepth=1 (displays disk space usage in byte readable format and also with max depth set to 1) 
* ./du.py --byteread --rootdir=/etc/ --modtime (displays disk space usage in byte readable format along with modtime)
* ./du.py --humanread --rootdir=/etc/ (displays disk space usage in human readable format)
* ./du.py --showtree --rootdir=/etc/yum.repos.d/ (displays disk space usage in tree format)

## Help

usage: du.py [-h] [--humanread] [--byteread] [--rootdir ROOTDIR]
             [--maxdepth MAXDEPTH] [--modtime] [--subtotal] 
       du.py [--showtree] [--rootdir ROOTDIR]

Arguments:

  -h, --help           show this help message and exit
  
  --humanread          human readable output (either human readable or byte
                       readable)
                       
  --byteread           byte readable output (either byte readable or human
                       readable)
                       
  --rootdir ROOTDIR    root directory (mandatory)
  
  --maxdepth MAXDEPTH  max-depth value (optional)
  
  --modtime            mod time value (optional)
  
  --subtotal           subtotal value (optional)
  
  --showtree           Show disk usage in tree format (optional); use showtree
                       only with rootdir
