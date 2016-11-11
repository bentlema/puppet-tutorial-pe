<-- [Back](01-Provision-Training-VMs.md#lab-1)

---

# **Lab #2** - Prepare to Install Puppet Enterprise on the **puppet** VM

---

## Overview

Time to complete:  10 minutes

In this lab we will complete some pre-installations steps to get our VM ready to take Puppet Enterprise

### Startup your Training VMs

If not already up and running...

```
vagrant up puppet
```

If you don't know the status of your vagrant-controlled VM's, you can always check with...

```
$ vagrant global-status
id       name         provider   state    directory
--------------------------------------------------------------------------------
4dd5ed7  puppet       virtualbox running  /Users/Mark/Vagrant/puppet-training-pe
070258c  gitlab       virtualbox poweroff /Users/Mark/Vagrant/puppet-training-pe
682eafe  agent        virtualbox poweroff /Users/Mark/Vagrant/puppet-training-pe
```

Notice that my **puppet** VM is running, but my **gitlab** and **agent** VM's are powered off.

## Login/Connect to your Training VM

```
$ vagrant ssh puppet
```

Once you're connected to the **puppet** VM, notice the bash shell pompt looks something like this:

```
[vagrant@puppet ~]$
```

Become root...

```
[vagrant@puppet ~]$ sudo su -
```

...and notice your shell prompt changes to:

```
Last login: Fri Oct 21 15:37:10 UTC 2016 on pts/0
[root@puppet ~]#
```

Now exit your root shell, and drop back to the vagrant user's shell...

```
[root@puppet ~]# exit
logout
[vagrant@puppet ~]$
```

Throughout the labs, you will need to execute many (if not most) commands as root.

Using sudo is a good habbit to develop, but starting a root shell can be more
convenient as long as you remember that you can severly damage a running system if
typing in the wrong command in the wrong place. (e.g. what if you accidently copy
and paste some text into a root shell, and it contains some commands that remove
the entire /lib directory?)

I will use **sudo** to run commands as root while in the vagrant user's shell, as
well as starting a root shell with **sudo su -** to illistrate these two options
below...

    - Use sudo to edit the /etc/hosts file
    - Start a root shell, and configure the host firewall

---

## Pre-installation Steps

There are a couple things we need to do to make our VM ready to take PE:

    - Add some entries to the /etc/hosts file
    - Open some ports through the host firewall

### Edit /etc/hosts

Edit **/etc/hosts** and add entries for localhost, as well as our 3 training VMs

    Note: For the purposes of this training, we will not use DNS.  We will rely
          on the /etc/hosts file for name resolution.  In a production deployment
          you would almost certainly want to use fully-qualified domain names (FQDN's),
          and very likely DNS as well.

```
sudo vi /etc/hosts
```

Delete the localhost lines in there (both IPv4 and IPv6 lines), which should be the
only two lines in there at this point, and add the following:

```
127.0.0.1      localhost
192.168.198.10 puppet.example.com puppet
192.168.198.11 agent.example.com  agent
192.168.198.12 gitlab.example.com gitlab
```

In a later lab, we will configure Puppet to make these /etc/hosts changes for us.

**Configure Firewall**

Open the host firewall to allow Puppet to work as per [PE Install Guide - Firewall Config](https://docs.puppetlabs.com/pe/3.8/install_system_requirements.html#firewall-configuration)

```shell
sudo su -
firewall-cmd --permanent --add-service=https   # to access Enterprise Console (default port 443)
firewall-cmd --permanent --add-port=3000/tcp   # to access configuration web interface during installation
firewall-cmd --permanent --add-port=8080/tcp   # to access PuppetDB metrics over HTTP
firewall-cmd --permanent --add-port=8081/tcp   # to access PuppetDB metrics over HTTPS
firewall-cmd --permanent --add-port=8140/tcp   # to access puppetmaster API and packages repo via HTTP
firewall-cmd --permanent --add-port=61613/tcp  # so that MCollective works (ActiveMQ communication)
firewall-cmd --reload
firewall-cmd --list-all
exit # drop out of root shell
```

The output of your **firewall-cmd --list-all** should look like this:

```
[vagrant@puppet ~]$ firewall-cmd --list-all
public (default, active)
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client https ssh
  ports: 3000/tcp 8140/tcp 8080/tcp 8081/tcp 61613/tcp
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:
```

Okay, now we're ready to run the Puppet Enterprise Installer...

---

Continue to **Lab #3** --> [Install Puppet Master](03-Install-Puppet-Master.md#lab-3)

---

### Further Reading ###

These links are not needed for this Lab, but for reference here's the PE Install Guide at the PuppetLabs web site:

Quick Start Guide:  <https://docs.puppetlabs.com/pe/3.8/quick_start_install_mono.html>

Detailed Install Guide:  <https://docs.puppetlabs.com/pe/3.8/install_basic.html>

Split Install:   <https://docs.puppetlabs.com/pe/3.8/install_pe_split.html>

LEI Install:   <https://docs.puppetlabs.com/pe/3.8/install_multimaster.html>

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley



