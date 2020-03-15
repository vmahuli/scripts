#!/bin/sh

# This script supports installation on centos, redhat and ubuntu servers

sudo=/usr/bin/sudo

rpm_req()
{
  # subroutine to install on centos and redhat
  $sudo yum install epel-release
  $sudo yum install python-pip
  $sudo yum install tree
  $sudo pip install argparse
}

dpkg_req()
{
  # subroutine to install on ubuntu
  $sudo apt-get update
  $sudo apt-get install python-pip
  $sudo apt-get install tree
  $sudo pip install argparse
}

#check for centos host and install requirements
rpm -ql centos-release | grep centos-release > /dev/null 2>&1
if [ $? = 0 ]; then
  rpm_req
fi

#check for redhat host and install requirements
rpm -qf /etc/redhat-release | grep redhat-release-server > /dev/null 2>&1
if [ $? = 0 ]; then
  rpm_req
fi

#check if it is a ubuntu system and install requirements
if [ -f /etc/lsb-release ]; then
  dpkg_req
fi
