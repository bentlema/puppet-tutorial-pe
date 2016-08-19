#!/bin/bash

#
# Note:  1.8.5 has a bug which prevents SSH auth after replacing insecure SSH key.
#        So don't use 1.8.5.  If you want to use a newer version, wait until 1.8.6
#        is released.
#

curl -O https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.dmg
curl -O https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.msi
curl -O https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_i686.rpm
curl -O https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.rpm
