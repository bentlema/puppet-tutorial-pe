
<-- [Back](/tutorial/01v-Provision-Training-VMs.md#start-here)

---
# Lab 2-V #
### Install Puppet Enterprise on the **puppet** VM ###
---

### Overview ###

Time to complete:  30 minutes

In this lab we will install Puppet Enterprise 3.8.X

* PE is free to install and evaluate
* When running PE without a license, you're limited to 10 agents

### Startup your Training VMs ###

If not already up and running...

Your **puppet** VM is already provisioned with enough memory and disk space to run PE, so let's install it.

    - Make sure your 'puppet' VM is up and running (if not, do a `vagrant up puppet`)
    - Get logged in to your 'puppet' VM with a `vagrant ssh puppet`

If you don't know the status of your vagrant-controlled VM's, you can always check with...

```
$ vagrant global-status
id       name         provider   state    directory
------------------------------------------------------------------------------
4dd5ed7  puppet       virtualbox running  /Users/Mark/Vagrant/puppet-training
070258c  gitlab       virtualbox poweroff /Users/Mark/Vagrant/puppet-training
682eafe  agent        virtualbox poweroff /Users/Mark/Vagrant/puppet-training
```

Notice that my **puppet** VM is running, but my **gitlab** and **agent** VM's are powered off.


---

### Pre-installation Steps ###

**Edit /etc/hosts**

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
192.168.198.11 gitlab.example.com gitlab
192.168.198.12 agent.example.com  agent
```

In a later lab, we will configure PE to make these /etc/hosts changes for us.

**Configure Firewall**

Open the host firewall to allow PE to work as per [PE Install Guide - Firewall Config](https://docs.puppetlabs.com/pe/3.8/install_system_requirements.html#firewall-configuration)

```shell
sudo su -
firewall-cmd --permanent --add-service=https   # to access Enterprise Console (default port 443)
firewall-cmd --permanent --add-port=3000/tcp   # to access configuration web interface during installation
firewall-cmd --permanent --add-port=8080/tcp   # to access PuppetDB metrics over HTTP
firewall-cmd --permanent --add-port=8081/tcp   # to access PuppetDB metrics over HTTPS
firewall-cmd --permanent --add-port=8140/tcp   # to access puppetmaster API and packages repo via HTTP
firewall-cmd --permanent --add-port=61613/tcp  # so that MCollective works (ActiveMQ communication)
firewall-cmd --reload
firewall-cmd --list-all-zones
exit # drop out of root shell
```

The output of your **firewall-cmd --list-all-zones** should look like this:

```
[snip]
public (default, active)
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client https ssh
  ports: 3000/tcp 8140/tcp 8080/tcp 8081/tcp 61613/tcp
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:
[snip]
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

