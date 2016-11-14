<-- [Back](/README.md#labs)

---

### **Lab #1** - Install software, and use Vagrant to deploy 3 training VMs

---

### Overview

Time to complete:  30 minutes

In the following lab you will install the following software:

1. **Git** (should already be installed) - the version control system
2. **VirtualBox** - the hypervisor used by default by Vagrant
3. **Vagrant** - the virtual machine deployment tool

...and then create 3 VirtualBox VMs named as follows:

1. **puppet**   (Puppet Master, PE Console, etc.)
3. **agent**    (A Puppet agent)
2. **gitlab**   (GitLab, which will also run the Puppet agent)

### Steps

* Download the needed software for this tutorial...

```
[puppet-tutorial-pe]$ cd share
[puppet-tutorial-pe/share]$ cd software
[puppet-tutorial-pe/share/software]$ ./download-all.sh
```

* Install VirtualBox
      - find the appropriate installer in the `puppet-tutorial-pe/share/software/virtualbox/` directory
      - Installers for Mac OS X and Windows are provided, but others can be downloaded as well
      - other installers available here: <https://www.virtualbox.org/wiki/Downloads>

* Start VirtualBox and configure 'Default Machine Folder' to place VM's in a directory other than the default (if you wish), then exit VirtualBox again.

* Install Vagrant
      - find the appropriate installer in `puppet-tutorial-pe/share/software/vagrant`
      - others available here: <https://www.vagrantup.com/downloads.html>

* cd into `puppet-tutorial-pe/`

* We install a Vagrant plugin to manage VirtualBox guest additions

* Then `vagrant up puppet` to provision the VM

```
cd puppet-tutorial-pe
vagrant plugin install vagrant-vbguest
vagrant up puppet
```

* once the **puppet** VM is provisioned, get familiar with vagrant, and confirm the VM specs are correct:

```
    vagrant ssh puppet              # to verify that you are able to login (should not be prompted for password)
    cat /etc/centos-release         # what CentOS release are we running?
    cat /proc/cpuinfo | grep proc   # how many vCPU's does the VM have? (should see 4 processors)
    lscpu                           # another way to see CPU info
    free -h                         # how much RAM is available on this VM?
    df -h /share                    # is our shared space mounted up? (should see 'share' filesystem mounted on /share)
    ls -al /share/software          # should see our puppet/ directory in there
    exit                            # and drop out of the VM, back to host OS shell prompt
```

### Stopping your Vagrant-managed VM

When you're done working through any particular lab, and want to stop your
VM's, you'd issue a `vagrant halt` command followed by the VM name, as follows:

```
    vagrant halt puppet        # and wait for VM to shutdown
```

### Starting your Vagrant-managed VM

If you issued a `vagrant halt puppet` to test the above, you may issue a `vagrant up puppet` before continuing on through the labs to start it back up again...

If all goes well with the above, we can be confident that our VM is working as expected, and let's move on.

### Login to your VM again...

Let's login to your puppet VM again with `vagrant ssh puppet`

You should see that `/share` is in the `df` output. This is your shared filesystem space that is also accessible outside of the VM

```
$ vagrant ssh puppet
Last login: Fri Oct 21 15:14:38 2016 from 10.0.2.2
[vagrant@puppet ~]$ df -h /share
Filesystem      Size  Used Avail Use% Mounted on
none            223G  206G   18G  93% /share
```

This `/share` directory is accessible **both** within your VM and from your host system.
For example, if you copy a file to `/share` within your VM, you will be able to get to it from your host OS at `puppet-tutorial-pe/share/` (and visa versa)

If for some reason, you do not see the `/share/` filesystem mounted up, try halting your VM and starting again.  Sometimes the VMware tools need to be updated, and a stop/start will trigger that:

```
[vagrant@puppet ~]$ exit
[puppet-tutorial-pe]$ vagrant halt puppet
[puppet-tutorial-pe]$ vagrant up puppet
[puppet-tutorial-pe]$ vagrant ssh puppet
```

...and check again.

### Explore more Vagrant commands

Get comfortable with Vagrant, and connecting to your VM.  The most useful commands you'll need are:

```
vagrant up <name>          # start the VM, and provision it if it's the first time
vagrant halt <name>        # shutdown the VM cleanly
vagrant global-status      # show the status of your VMs (powered on or off)
vagrant destroy <name>     # if you want to completely destroy your VM and start over
vagrant ssh <name>         # connect to your VM with ssh
vagrant ssh-config <name>  # show ssh config in case you want to use PuTTY to connect to your VM
```

### Provision two more VMs

You'll also need to provision 2 more VMs, one for **GitLab**, and one more
which will run the puppet **agent**.  (Actually, all 3 will run the puppet
agent, but we create a separate small VM for testing with so we don't have
to worry about breaking something while we are testing.)

```
vagrant up gitlab          # provision the VM for your GitLab server
vagrant up agent           # provision your VM that will be one of your puppet agents
```

Once you provision your **gitlab** and **agent** VMs, you should see them in the output of **vagrant global-status**

```
$ vagrant global-status
id       name         provider   state    directory
------------------------------------------------------------------------------
4dd5ed7  puppet       virtualbox running  /Users/Mark/Vagrant/puppet-tutorial-pe
070258c  gitlab       virtualbox running  /Users/Mark/Vagrant/puppet-tutorial-pe
682eafe  agent        virtualbox running  /Users/Mark/Vagrant/puppet-tutorial-pe

The above shows information about all known Vagrant environments
on this machine. This data is cached and may not be completely
up-to-date. To interact with any of the machines, you can go to
that directory and run Vagrant, or you can use the ID directly
with Vagrant commands from any directory. For example:
"vagrant destroy 1a2b3c4d"
```

### Validate your training environment

We've used Vagrant to provision 3 training VMs.  If you're curious how the
VM's are configured, take a peek at the [puppet-tutorial-pe/Vagrantfile](/Vagrantfile)

We've used a custom base box that already has some things we need (packages, config, etc.)
This custom base box already has entries in `/etc/hosts` that we want/need (since we will
rely on /etc/hosts to resolve names within our training environment.)

Each VM should have the following contnets in their `/etc/hosts` file:

```
127.0.0.1       localhost
192.168.198.10  puppet.example.com  puppet
192.168.198.11  agent.example.com   agent
192.168.198.12  gitlab.example.com  gitlab
```

With all 3 of your VMs up and running, validate that you can ping each using
the FQDN as well as the short name.

For example:

```
[vagrant@puppet ~]$ ping puppet.example.com
PING puppet.example.com (192.168.198.10) 56(84) bytes of data.
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=1 ttl=64 time=0.043 ms
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=2 ttl=64 time=0.098 ms
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=3 ttl=64 time=0.075 ms
^C
--- puppet.example.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.043/0.072/0.098/0.022 ms

[vagrant@puppet ~]$ ping puppet
PING puppet.example.com (192.168.198.10) 56(84) bytes of data.
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=1 ttl=64 time=0.052 ms
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=2 ttl=64 time=0.088 ms
64 bytes from puppet.example.com (192.168.198.10): icmp_seq=3 ttl=64 time=0.098 ms
^C
--- puppet.example.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.052/0.079/0.098/0.021 ms
```

You should also be able to ssh between each VM as either the **vagrant** user
or the **root** user.  The default password is simply **"vagrant"**.  Give it
a try if you like.  You should also be able to ssh in to any of your VMs from
the host itself.  You can learn the ssh port to use using the `vagrant ssh-config`
command.  Give it a try:

```
[puppet-tutorial-pe]$ vagrant ssh-config puppet
Host puppet
  HostName 127.0.0.1
  User vagrant
  Port 22022
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/Mark/.vagrant.d/boxes/bentlema-VAGRANTSLASH-centos-7.2-64/1.0.0/virtualbox/vagrant_private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Take note that the NAT'ed port is 22022.

```
[puppet-tutorial-pe]$ ssh root@127.0.0.1 -p 22022
Warning: Permanently added '[127.0.0.1]:22022' (ECDSA) to the list of known hosts.
root@127.0.0.1's password:
Last login: Fri Nov 11 21:57:06 2016
[root@puppet ~]# exit
logout
Connection to 127.0.0.1 closed.
```

This ability to ssh between our VMs will become useful in a later lab
(when we configure R10K to pull code from GitLab.)

### Next up...

This concludes Lab #1.  You should now have 3 VMs up and running named as
shown above in the **global-status** output above.


If you're not planning to continue to the next lab right away, you may want
to halt all of your training VM's.  Make sure you've exited the ssh session
of each VM, and back down to the shell prompt on your workstation, then issue
the `vagrant halt` for each VM as follows:

```
vagrant halt puppet
vagrant halt agent
vagrant halt gitlab
```

Note:  Doing a **halt** will gracefully shutdown your VM, not simply power
it off.  You do **not** need to shutdown the OS running in the VM first.  If you
do that, the **vagrant halt** wont be able to shutdown gracefully, will
timeout trying, and then power off the VM.

---

Continue on to **Lab #2** --> [Prepare to Install Puppet Enterprise](02-Prep-to-Install-Puppet-Master.md#lab-2)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

