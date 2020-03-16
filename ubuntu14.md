## gnutls_handshake() failed: Handshake failed

For Ubuntu14, the version of git/the SSL library packaged with Ubuntu 14.04 does not support one of the algorithms used by the certificate that is presented by the server.
Ubuntu 14.04  is end-of-life
I also tried to compile Git with Openssl by following below steps.


sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 78BD65473CB3BD13\
sudo apt-get update\
sudo apt-get install build-essential fakeroot dpkg-dev libcurl4-openssl-dev\
sudo apt-get build-dep git\
sudo apt-get install build-essential fakeroot dpkg-dev libcurl4-openssl-dev\
mkdir ~/git-openssl\
cd ~/git-openssl\
apt-get source git\
dpkg-source -x git_1.9.1-1ubuntu0.10.dsc\
cd git-1.9.1\
edit debian/control file, replace libcurl4-gnutls-dev with libcurl4-openssl-dev\
edit debian/rules file, remove the TEST=test line\
sudo ./configure\
sudo make\
sudo make install
