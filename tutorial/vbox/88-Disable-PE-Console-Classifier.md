
---

### Lab ??
### Disable the PE Console Node Classifier

---

### Overview ###

Time to complete:  60 minutes

```
TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO

We need to talk about the site.pp, and the **node** declaration, as well as the PE Console and classifying nodes.

TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
```

### What classes are assigned by the PE Console? ###

On any puppetized host you can find what classes are assigned to it (how it is "classified") by looking at the contents of the classes.txt file.  The classes.txt is generated upon every puppet agent run.

Here are the classes we see assigned to our agent node:

```
[root@agent ~]# find /var -name classes.txt
/var/opt/lib/pe-puppet/classes.txt
[root@agent ~]# cat /var/opt/lib/pe-puppet/classes.txt | sort | uniq
common_hosts
common_packages
default
ntp
ntp::config
ntp::install
ntp::params
ntp::service
puppet_enterprise
puppet_enterprise::mcollective::server
puppet_enterprise::mcollective::server::certs
puppet_enterprise::mcollective::server::facter
puppet_enterprise::mcollective::server::logs
puppet_enterprise::mcollective::server::plugins
puppet_enterprise::mcollective::service
puppet_enterprise::params
puppet_enterprise::profile::agent
puppet_enterprise::profile::mcollective::agent
puppet_enterprise::symlinks
settings
timezone
timezone::params
```

Here are teh classes we see assigned to our puppet master node:

```
[root@puppet ~]# cat /var/opt/lib/pe-puppet/classes.txt | sort | uniq
common_hosts
common_packages
default
ntp
ntp::config
ntp::install
ntp::params
ntp::service
pe_concat::setup
pe_console_prune
pe_repo
pe_repo::platform::el_7_x86_64
pe_staging
puppet_enterprise
puppet_enterprise::amq
puppet_enterprise::amq::certs
puppet_enterprise::amq::config
puppet_enterprise::amq::service
puppet_enterprise::console
puppet_enterprise::console::config
puppet_enterprise::console::console_auth_config
puppet_enterprise::console::database
puppet_enterprise::console::service
puppet_enterprise::console_services
puppet_enterprise::license
puppet_enterprise::master
puppet_enterprise::master::puppetserver
puppet_enterprise::mcollective::server
puppet_enterprise::mcollective::server::certs
puppet_enterprise::mcollective::server::facter
puppet_enterprise::mcollective::server::logs
puppet_enterprise::mcollective::server::plugins
puppet_enterprise::mcollective::service
puppet_enterprise::packages
puppet_enterprise::params
puppet_enterprise::profile::agent
puppet_enterprise::profile::amq::broker
puppet_enterprise::profile::certificate_authority
puppet_enterprise::profile::console
puppet_enterprise::profile::console::apache_proxy
puppet_enterprise::profile::console::certs
puppet_enterprise::profile::console::console_services_config
puppet_enterprise::profile::master
puppet_enterprise::profile::master::auth_conf
puppet_enterprise::profile::master::classifier
puppet_enterprise::profile::master::console
puppet_enterprise::profile::master::mcollective
puppet_enterprise::profile::master::puppetdb
puppet_enterprise::profile::mcollective::agent
puppet_enterprise::profile::mcollective::console
puppet_enterprise::profile::mcollective::peadmin
puppet_enterprise::profile::puppetdb
puppet_enterprise::puppetdb
puppet_enterprise::puppetdb::database_ini
puppet_enterprise::puppetdb::jetty_ini
puppet_enterprise::puppetdb::service
puppet_enterprise::symlinks
settings
timezone
timezone::params
```

Wow!  Where did all those come from?



### More about node classification... ###


In Puppet Enterprise, the so-called 'PE Console' actualy comes configured
out-of-the-box as an "External Node Classifier" (or ENC).  Unfortunately,
in a "Large Environment Install" (or "LEI") the Console becomes a bottleneck
to scaling out.  When your install base exceeds 1000 or so agents, and every
agent needs to wait for the PE Console to tell the puppet master what environment
the agent belongs to, and what classes to apply to it, things go slow.

For this reason, Puppet Labs disables the PE Console ENC.  The settings 
that controls this is in the puppet.conf, as is:

```
[master]
node_terminus = classifier
```

You might think you can just edit the puppet.conf and change this setting
to `node_terminus = plain` and call it good.  Go ahead and try that, and
run puppet again, and see what happens:

```
[root@puppet puppet]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for puppet
Info: Applying configuration version '1454024977'
Notice: /Stage[main]/Puppet_enterprise::Profile::Master::Classifier/Pe_ini_setting[node_terminus]/value: value changed 'plain' to 'classifier'
Info: Class[Puppet_enterprise::Profile::Master::Classifier]: Scheduling refresh of Service[pe-puppetserver]
```

What happens is that puppet is configured to configure itself, and so sees
that it's config changed, and changes it back to what it thinks it should be.
So how do we configure puppet to configure the puppet master the way we
want?

Because you didn't restart the pe-puppetserver service, when you run the agent,
it talks back to the master (which happens to be running on the same host, but
hasn't yet re-read it's edited config file) and the master re-applies what it
believes it the config should be.  Puppet is just doing what it's made to do!

Edit the puppet.conf again, and change node_terminus to plain, and restart the puppet master with:

```
[root@puppet puppet]# systemctl restart pe-puppetserver
```

If you try to run the puppet agent now, you'll find that the master has lost its mind, and 
doesn't know it's a master.  Don't do that.

Then add the following to the site.pp, and run `puppet agent -t`

```
class { 'puppet_enterprise':
  certificate_authority_host   => 'puppet.example.com',
  puppet_master_host           => 'puppet.example.com',
  console_host                 => 'puppet.example.com',
  puppetdb_host                => 'puppet.example.com',
  database_host                => 'puppet.example.com',
  mcollective_middleware_hosts => [ 'puppet.example.com' ]
}

include puppet_enterprise::profile::agent
include puppet_enterprise::profile::mcollective::agent

node puppet {
  class { 'puppet_enterprise::profile::master':
      classifier_host => false,
  } ->
  pe_ini_setting { 'disable_console_classifier':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'node_terminus',
    value   => 'plain',
    notify  => Service['pe-puppetserver']
  }
}
```






```







NOTE:

Need to re-do everything following, as I re-did the above code







```







See Zee's "LEI Wrapper" module to accomplish this, and
simplify PE configuration.

<https://github.com/pizzaops/pizzaops-lei_wrapper>

Without this, you would not be able to set the environment in the agent's
puppet.conf, as the PE Console ENC would override that.

Our tiny training environment is certainly not an LEI, but for the sake
of learning, let's go ahead and walk through the process of disabling
the PE Console ENC.

---

### Disable the PE Console ENC ###

This really needs to be split out into a separate lab...

To disable the use of the PE Console as an ENC, we have to simply:

* Edit puppet.conf and set **node_terminus = plain**
* Ensure that the next puppet run doesn't change it back
* Ensure that without the PE Console ENC, are master and agents are still properly classified

We could simply use the pizzaops-lei_wrapper module, but in this lab, we will
walk through the steps manually so that we understand all that is happening...


an copy-and-paste the above code in to our
site.pp as we will require this in a later lab.  As we are adding this
to our **node puppet** make sure we replace the existing definition, or
only copy and paste the contents of the code within the existing definition.

This is only half of what we need to do, though.  We also need to
change the value of node_terminus to **plain** in our puppet.conf.  Because
this setting in the puppet.conf on the master is actually managed by 
puppet itself, we have to jump through a few hoops.

via the PE Console:

* Login as 'admin'
* Click **Classification** tab
* Click **PE Master**
* Click **Classes** sub-tab
* Scroll down to where you see **Class: puppet_enterprise::profile::master**
* Under **Parameter** find **classifier_host** in the list and set to **false**
* Click **Add Parameter** to save the value
* Click **Commit 1 change** at the bottom of the screen

Now, run **puppet agnet -t** and you should see the setting be changed, and the puppetmaster restarted:

```
Notice: /Stage[main]/Main/Node[puppet]/Pe_ini_setting[disable_console_classifier]/value: value changed 'classifier' to 'plain'
Info: /Stage[main]/Main/Node[puppet]/Pe_ini_setting[disable_console_classifier]: Scheduling refresh of Service[pe-puppetserver]
Notice: /Stage[main]/Puppet_enterprise::Master::Puppetserver/Service[pe-puppetserver]: Triggered 'refresh' from 1 events
```

### But! ###

What else have we just done?  We've just disabled the PE Console as an ENC,
which is what classified the puppet master.  The puppet master no longer knows
that it's a puppet master.  So, let's fix that by adding the following to
our site.pp within the **node puppet** definition.

```
include puppet_enterprise::profile::master
```



---

Continue to **Lab #5** --> [Practice doing some puppet code, and puppet runs](05-Puppet-Code-Practice.md)

---

Further Reading:

For more info on how the site.pp **main manifest** is configured and used,
see the PuppetLabs docs at:

<https://docs.puppetlabs.com/puppet/3.8/reference/dirs_manifest.html>

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

