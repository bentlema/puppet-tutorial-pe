#!/bin/bash

# http://download.virtualbox.org/virtualbox/5.0.16/
# http://download.virtualbox.org/virtualbox/5.1.2/
# http://download.virtualbox.org/virtualbox/5.0.26/VirtualBox-5.0.26-108824-OSX.dmg

VERSION="5.0.16"
BUILD="105871"

VERSION="5.0.26"
BUILD="108824"

# Don't use until Vagrant 1.8.6 comes up (1.8.5 is broken)
#VERSION="5.1.2"
#BUILD="108956"

mkdir -p ${VERSION}-${BUILD} && cd ${VERSION}-${BUILD} || exit

curl -O http://download.virtualbox.org/virtualbox/${VERSION}/MD5SUMS
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/SHA256SUMS
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/UserManual.pdf
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/SDKRef.pdf
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VBoxGuestAdditions_${VERSION}.iso

# https://www.virtualbox.org/wiki/Downloads
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-${VERSION}-${BUILD}-Win.exe
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-${VERSION}-${BUILD}-OSX.dmg
#curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-${VERSION}-${BUILD}-SunOS.tar.gz

# https://www.virtualbox.org/wiki/Linux_Downloads
#curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-5.0-${VERSION}_${BUILD}_el6-1.x86_64.rpm
#curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-5.0-${VERSION}_${BUILD}_el7-1.x86_64.rpm
#curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-5.0-${VERSION}_${BUILD}_fedora18-1.x86_64.rpm
#curl -O http://download.virtualbox.org/virtualbox/${VERSION}/VirtualBox-5.0-${VERSION}_${BUILD}_fedora22-1.x86_64.rpm

# Extension Pack
curl -O http://download.virtualbox.org/virtualbox/${VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VERSION}-${BUILD}.vbox-extpack

