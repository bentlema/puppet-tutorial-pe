FROM centos:6.8
MAINTAINER Mark Bentley <bentlema@yahoo.com>
ENV container docker
RUN yum install -y openssh-server openssh-clients postfix cronie net-tools iproute pciutils system-logos which libxml2 dmidecode net-tools virt-what apr apr-util curl mailcap libjpeg libtool-ltdl unixODBC libxslt zlib gtk2 tree wget
RUN chkconfig sshd on
RUN chkconfig postfix on
RUN echo 'foobar23' | passwd root --stdin
RUN rm -f /etc/init/tty.conf
RUN rm -f /etc/init/start-ttys.conf
ADD setlocale.sh /etc/profile.d
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]
