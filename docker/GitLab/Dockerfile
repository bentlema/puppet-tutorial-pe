FROM gitlab/gitlab-ce
MAINTAINER Mark Bentley <bentlema@yahoo.com>

# Needed to allow root user to login with password
RUN sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

# Search for commented out PasswordAuthentication option, and un-comment it
RUN sed -i '/^#PasswordAuthentication/s/^#//' /etc/ssh/sshd_config

# Search for PasswordAuthentication set to no, and change to yes
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Needed to allow root user to login with password
RUN sed -i '$aAllowUsers root' /etc/ssh/sshd_config

CMD ["/sbin/init"]
