#!/bin/bash
#
# Not all versions of vagrant work with all version of VirtualBox
#
# Versions that I've tested that work well together:
#
#     Vagrant 1.8.4 + VirtualBox 4.0.x
#
# Note:  1.8.5 has a bug which prevents SSH auth after replacing insecure SSH key.
#
REL='1.8.4'
#REL='1.8.5'  #  <-- Broken release / Do not use
#REL='1.8.6'  #  <-- Not tested / Do not use yet
#REL='1.8.7'  #  <-- Possible bug on MacOS / Do not use yet

curl -O "https://releases.hashicorp.com/vagrant/${REL}/vagrant_${REL}.dmg"
curl -O "https://releases.hashicorp.com/vagrant/${REL}/vagrant_${REL}.msi"
curl -O "https://releases.hashicorp.com/vagrant/${REL}/vagrant_${REL}_i686.rpm"
curl -O "https://releases.hashicorp.com/vagrant/${REL}/vagrant_${REL}_x86_64.rpm"
