

   docker run -d                         \
      --memory 4G                        \
      --net example.com                  \
      --ip 192.168.198.10                \
      -p 22022:22                        \
      -p 22443:443                       \
      -p 22080:8080                      \
      -p 22081:8081                      \
      -p 22140:8140                      \
      -p 22000:3000                      \
      --name puppet                      \
      --hostname puppet.example.com      \
      --network-alias=puppet.example.com \
      --network-alias=puppet             \
      --dns-search=example.com           \
      --volume ${BASEDIR}/share:/share   \
      bentlema/centos6-puppet            \
      /sbin/init












I spent 2 days trying to get the PE 3.8 installer to work on Centos 7.2.1511, but
ran into an annoying timeout issue with systems starting pe-puppetserver.

I even edited the /usr/lib/systemd/system/pe-puppetserver.service file and increased
the timeout to 300 seconds (followed by a systemctl daemon-reload), but the service
still failed to start. (Relevant settings is TimeoutStartSec=300).  The timeout setting
did take effect, but after 5 minutes, my 'systemctl start pe-puppetserver' would come
back with the same error.

The odd thing is I could start the puppet master manually without issue.  So, rather
than waste too much time trying to figure out the systemd issue, I opted to try on
Centos 6, and it works just fine.

# TODO: Look into what this person did in his Dockerfile for Centos and
# see if there is anything useful
https://hub.docker.com/r/feduxorg/centos/

Here is the Dockerfile I used to build the puppet base image:

FROM centos:6.8
MAINTAINER Mark Bentley <bentlema@yahoo.com>
ENV container docker
RUN yum install -y openssh-server openssh-clients postfix cronie net-tools iproute pciutils system-logos which libxml2 dmidecode net-tools virt-what apr apr-util curl mailcap libjpeg libtool-ltdl unixODBC libxslt zlib gtk2
RUN chkconfig sshd on
RUN chkconfig postfix on
RUN echo 'foobar23' | passwd root --stdin
ADD setlocale.sh /etc/profile.d
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]

Then build with:

docker build --rm -t bentlema/centos6-puppet .

Now we can use this image when we start our container...

Create Docker Network which will be used by the 3 containers we will create
  - Puppet agents will talk to the Puppet master over this example.com network
  - R10K will pull code from the GitLab server over this example.com network
  - etc.

docker network create --subnet=192.168.198.0/24 example.com

To start up the container for the Puppet Master:

   export BASEDIR=/Users/mbentle8/Documents/Git/BitBucket/puppet-training
   cd $BASEDIR

   docker run -d                         \
      --memory 4G                        \
      --net example.com                  \
      --ip 192.168.198.10                \
      -p 22022:22                        \
      -p 22443:443                       \
      -p 22080:8080                      \
      -p 22081:8081                      \
      -p 22140:8140                      \
      -p 22000:3000                      \
      --name puppet                      \
      --hostname puppet.example.com      \
      --dns-search=example.com           \
      --network-alias=puppet             \
      --network-alias=puppet.example.com \
      --volume ${BASEDIR}/share:/share   \
      bentlema/centos6-puppet            \
      /sbin/init

#
# Login to the puppet container, and lets install Puppet Enterprise
#

docker exec -it puppet /bin/bash

# OR

ssh -l root localhost -p 22022

#
# Run the installer
#

cd /share/software/puppet-enterprise/puppet-enterprise-3.8.5-el-6-x86_64
./puppet-enterprise-installer

#
# The entire log file of the installation can be found in...
#
#     /var/log/pe-installer/installer.log
#
# ...if you are curious and wish to take a peek.

#
# Note:  If you are returning to this training after creating the containers
#        and stopping them, you will need to re-start them with:
#
#           docker start <container name>
#
#        Also, if the services do not restart auto-matically (I'm still working on this)
#        then you may do a puppet run manually, which will cause puppet to start any
#        puppet-managed services (like the PE Console to start up)
#
#           puppet agent -t
#
#
# Next, let us create our test container for running a puppet agent
#

   export BASEDIR=/Users/mbentle8/Documents/Git/BitBucket/puppet-training
   cd $BASEDIR

   docker run -d                        \
      --memory 512M                     \
      --net example.com                 \
      --ip 192.168.198.12               \
      -p 24022:22                       \
      --name agent                      \
      --hostname agent.example.com      \
      --dns-search=example.com          \
      --network-alias=agent             \
      --network-alias=agent.example.com \
      --volume ${BASEDIR}/share:/share  \
      bentlema/centos6-puppet           \
      /sbin/init

#
# We use the same image as we did for puppet just to keep things simple...
# Now let us login to the agent container and install the puppet agent
#

ssh -l root  127.0.0.1 -p 24022

curl -k --tlsv1 https://puppet:8140/packages/current/install.bash | bash

#
# One the Master
#

puppet cert sign agent.example.com

#
# On the Agent, do a test run
#

puppet agent -t

#
# Works!
#

#
# Next, let us get GitLab up and running...
#

   export BASEDIR=/Users/mbentle8/Documents/Git/BitBucket/puppet-training
   cd $BASEDIR

   docker run -d                                      \
      --memory 2G                                     \
      --net example.com                               \
      --ip 192.168.198.11                             \
      -p 23022:22                                     \
      -p 23080:80                                     \
      -p 23443:443                                    \
      --name gitlab                                   \
      --hostname gitlab.example.com                   \
      --dns-search example.com                        \
      --network-alias gitlab                          \
      --network-alias gitlab.example.com              \
      --restart always                                \
      --volume ${BASEDIR}/gitlab/config:/etc/gitlab   \
      --volume ${BASEDIR}/gitlab/logs:/var/log/gitlab \
      --volume ${BASEDIR}/gitlab/data:/var/opt/gitlab \
      --volume ${BASEDIR}/share:/share                \
      gitlab/gitlab-ce

#
# We shouldn't really need to get into the GItLab docker container,
# but if you'd like to see inside, it's an Ubuntu system, and you
# can enter with:
#

docker exec -it gitlab /bin/bash

#
# Later on, we may install the puppet agent on this Ubuntu system, just for the fun of it.
# I still need to check if the 8GB system has enough resources to run all 3 docker
# containers, as with VirtualBox I was not able to with the system swapping a lot.
#
# This wont work out of the box, as we have not yet added other platforms to the
# puppet config, so the Ubuntu installer and packages are not on the master yet.
#

curl -k --tlsv1 https://puppet:8140/packages/current/install.bash | bash
























































#
# EVERYTHING BELOW are just old notes that I need to clean up
#

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i '/PasswordAuthentication/s/^#//g' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i "\$aAllowUsers root"

#
# Those /etc/hosts entries can probably go away eventually.
# Once I get the other 2 containers running, Docker should
# add their names/IPs to the internal DNS server, but need
# to test that...
#
#      --add-host "gitlab.example.com gitlab":192.168.198.11 \
#      --add-host "agent.example.com  agent":192.168.198.12  \
#
# Some other options to experiment with
# Many of these I was using with Centos7 and systemd, but
# never got it working fully.
#
#      --volume /sys/fs/cgroup:/sys/fs/cgroup                \
#      -e "container=docker"                                 \
#      --cap-add=SYS_ADMIN                                   \
#      --security-opt seccomp=unconfined                     \
#      --dns 8.8.8.8                                         \
#      --add-host "puppet.example.com puppet":192.168.198.10 \
#
# After starting the container, we need to set a root password
# that we know, so that we can then ssh in to the container.
# From another terminal, login as root and change the root password
#

docker exec -u 0 -it puppet bash

#
# Note: we dont need to set the password now, as I have added that
# to the Dockerfile build for the bentlema/centos6-puppet image
#

Set the root password, then logout, and stop the container

docker stop puppet
docker commit -m "Set root password" -a "Mark Bentley" puppet bentlema/centos6-puppet
docker start puppet






#
# Add to /etc/profile/setlocale.sh
# (Otherwise we get an PE Installer error about invalid byte code)
#

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#
# Install some things
#

yum install -y openssh-server net-tools iproute cronie


# This isn't necessary, as we've configured systemd to run, and it handles all of this.
#
#sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ssh-keygen -f /etc/ssh/ssh_host_key -N '' -t rsa1
#ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
#ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
#ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
#ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
#/usr/sbin/sshd

#
# Install Puppet Enterprise deps
#

yum install -y pciutils system-logos which libxml2 dmidecode net-tools virt-what apr apr-util curl mailcap libjpeg libtool-ltdl unixODBC libxslt zlib


(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done)
rm -f /lib/systemd/system/multi-user.target.wants/*;
rm -f /etc/systemd/system/*.wants/*;
rm -f /lib/systemd/system/local-fs.target.wants/*;
rm -f /lib/systemd/system/sockets.target.wants/*udev*;
rm -f /lib/systemd/system/sockets.target.wants/*initctl*;
rm -f /lib/systemd/system/basic.target.wants/*;
rm -f /lib/systemd/system/anaconda.target.wants/*;









Some links I found useful:

https://hostpresto.com/community/tutorials/how-to-create-a-docker-container-using-an-interactive-shell/
http://askubuntu.com/questions/505506/how-to-get-bash-or-ssh-into-a-running-container-in-background-mode
http://blog.arungupta.me/attach-shell-to-docker-container/
https://hub.docker.com/_/centos/
https://docs.docker.com/engine/tutorials/usingdocker/
http://stackoverflow.com/questions/25267372/correct-way-to-detach-from-a-container-without-stopping-it
https://docs.docker.com/engine/examples/running_ssh_service/
http://stackoverflow.com/questions/27937185/assign-static-ip-to-docker-container































Let's start playing around with Docker, and see if we can use it instead of Vagrant, or use
Vagrant's docker provider.

To start up and interactive bash shell in a Centos container:

   export BASEDIR=/Users/mbentle8/Documents/Git/BitBucket/puppet-training
   cd $BASEDIR
   docker run -i -t --name puppetmaster -v ${BASEDIR}/docker:/docker centos:7.2.1511 bash

Some links I found useful:

https://hostpresto.com/community/tutorials/how-to-create-a-docker-container-using-an-interactive-shell/
http://askubuntu.com/questions/505506/how-to-get-bash-or-ssh-into-a-running-container-in-background-mode
http://blog.arungupta.me/attach-shell-to-docker-container/
https://hub.docker.com/_/centos/
https://docs.docker.com/engine/tutorials/usingdocker/





Need to look into how to use Docker Containers, as it could be a way we could use an 8GB system to complete the labs, where full VM's use too much memory, and cause an 8GB system to go slow...


docker run -d --name gitlab-ce \
    -p 8443:443 \
    -p 8080:80 \
    -p 2222:22 \
    --volume $PWD/gitlab/config:/etc/gitlab \
    --volume $PWD/gitlab/logs:/var/log/gitlab \
    --volume $PWD/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce


Vagrant can deploy to Docker containers, as it has a Docker provider:   https://www.vagrantup.com/docs/docker/basics.html


