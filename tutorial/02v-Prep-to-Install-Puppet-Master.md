
# Puppet + Git Training #

---

### Lab #2-A - Install Puppet Enterprise on the **puppet** VM ###

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

### Run The Installer ###

Now let's un-compress/de-archive the PE installation tarball, and install...

```shell
cd /vagrant/software/puppet-enterprise
tar xzvf puppet-enterprise-3.8.4-el-7-x86_64.tar.gz
cd puppet-enterprise-3.8.4-el-7-x86_64
sudo ./puppet-enterprise-installer
```

The installer will prompt you:

    ?? Install packages and perform a guided install? [Y/n]

Press Enter to accept the default 'Y' and then you'll see:

    Installing setup packages.
    Please go to https://puppet.example.com:3000 in your browser to continue installation.
    Be sure to use https:// and that port 3000 is reachable through the firewall.

Remember that we have **forwarded port 3000 to 22000** on our workstation, so...

* Use web browser to connect to:    <https://127.0.0.1:22000/>
* Click **Monolithic Install**
* For FQDN, enter **puppet.example.com**
* For DNS alias, enter **puppet**
* Use the Puppet 4 parser:  Leave **un-checked**
* Select: Install PostgreSQL on the PuppetDB host for me.
* Click **Submit**
* Click **Continue**

    Note:  Don't worry about the memory and disk space warnings.  The amount of memory and disk space we've provisioned will be just fine for this training exercise.

You will see this:

    We're checking to make sure the installation will work correctly
    Verify that 127.0.0.1 can resolve puppet.
    Verify root access on puppet.
    Verify that DNS is properly configured for puppet.
    Verify that your hardware meets requirements on puppet.
    [puppet] We found 3,792 MB RAM. We recommend at least 6,144 MB.
    Verify that 127.0.0.1 has a PE installer that matches puppet's OS.
    Verify that '/opt' and '/var' contain enough free space on puppet.
    [puppet] Insufficient space in '/opt' (16 GB); we recommend at least 100 GB for a production environment.

Click **Deploy Now**

    Intalling your deployment
    Install Puppet Enterprise on puppet.
    Verify that Puppet Enterprise is functioning on puppet.
    [puppet] The puppet agent ran successfully.
    Verify that MCollective is functioning on puppet.
    Backup installer log files to puppet.

During the installation process you may click on 'Log view' to see what is happening behind the scenes, and then click 'Summary View' to return back to the overview.
Note:  Once the installation completes, clicking the 'Start Using Puppet Enterprise' button will not work, as we are port-forwarding from a VM to our localhost.

---

### Login to the PE Console ###

We've forwarded port 443 from our puppet VM to port 22443 on our workstation, so you should be able to connect to the PE Console via the URL:

<https://127.0.0.1:22443/>

Login as **admin** and enter the admin password you chose during the install.

If you forgot (or not sure what you typed) you can find the password in the answers file:

     sudo grep q_puppet_enterpriseconsole_auth_password /opt/puppet/share/installer/answers/*.answers

Probabbly a good idea to **change it**...!

Believe it or not, that's all there is to installing a 'Monolithic' puppet
server.  A 'Split' and/or 'Large Environment Install' is a bit more work, as
we'd be splitting up the various parts of PE on to separate VM's, as well as
deploying multiple compile masters behind a loadbalancer.  We wont be covering
a Split/LEI in this training.  If you're interested in learning more about
that, you may read about it in the [PE Installation Guide](https://docs.puppetlabs.com/pe/3.8/install_pe_split.html)

Look around the PE console.  You should see 1 agent is registered called puppet.example.com.  This is your Puppet Master!

To change the 'admin' account password, click on 'admin' in the top right corner, and select 'My Account'.  You should
find a 'Reset password' link near the top/right of that page.

Test your PE install from the shell prompt run puppet with sudo, or become root and run it:

```
     sudo puppet agent -t
```

or

```
     sudo su -
     puppet agent -t
```

Note:  Even on the Puppet Master, the Agent runs regularly.  The Master configures itself through Puppet.  Be aware, if you make
a puppet change that affects all nodes, you will be affecting the master config as well (e.g. a global change to /etc/hosts).
Do not disable the puppet agent on the master thinking that you're guarding against accidental changes that could break your
puppet infrastructure.  The agent runs on the master are required for mcollective key distribution (they get stored in the PuppetDB
and then installed on the other nodes of puppet infra via exported resources).  Also, there are certain configuration params
in the puppet.conf on the master that are managed by puppet itself.

```shell
[vagrant@puppet ~]$ sudo su -
Last login: Tue Jan 12 00:04:13 UTC 2016 on pts/1
[root@puppet ~]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for puppet
Info: Applying configuration version '1452623722'
Notice: Finished catalog run in 5.54 seconds
```

Not too exciting.  We have confirmed that the agent run succeeds, so we know the puppetmaster is up and running and able
to build a catalog for itself. Good.

If you're on a terminal that supports ANSI color, you'll notice that the text
is in GREEN.  If there are any puppet errors during a puppet run, those errors
would show up in RED text.

---

Continue to **Lab #3** --> [Install Puppet Master](03-Install-Puppet-Master.md)

---

### Further Reading ###

These links are not needed for this Lab, but for reference here's the PE Install Guide at the PuppetLabs web site:

Quick Start Guide:  <https://docs.puppetlabs.com/pe/3.8/quick_start_install_mono.html>

Detailed Install Guide:  <https://docs.puppetlabs.com/pe/3.8/install_basic.html>

Split Install:   <https://docs.puppetlabs.com/pe/3.8/install_pe_split.html>

LEI Install:   <https://docs.puppetlabs.com/pe/3.8/install_multimaster.html>

---

