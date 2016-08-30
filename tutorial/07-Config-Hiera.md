
---
# Lab 7 #
### Configure Hiera ###
---

### IN DEVELOPMENT ###

Note:  The following sections are still be heavily edited/expanded.

### Overview ###

Time to complete:  60 minutes

In this lab we will:

 - Configure Hiera
 - Use Hiera to classify our nodes

---

### What is Hiera? ###

Hiera is a database that you can query in your Puppet code.  Hiera stores
data in YAML or JSON formatted flat text files.  We refer to the data as
**Hiera Data** and Hiera allows us to store data in a hierarchical fashion
such that a query can return different results depending on the value of
system facts or other puppet variables.


### Why is Hiera useful, and why do we want to use it? ###

The two key reasons we like to use Hiera are:

  - Node Classification (Potentially much nicer than using **node** definitions in the site.pp)
  - Module Portability (Keeping site/company-specific data separate from the actual code)

Hiera, though not technically an [External Node Classifier](https://docs.puppet.com/guides/external_nodes.html)
(ENC), can be used like one.  Not only can you
declare classes inside a node definition (as we've seen in previous labs) you
can use Hiera to tie a class to a node.  You can also use Hiera to pass class
parameters in to a class (including classes within modules).  Or you can use
Hiera to store arbitrary data as name/value pairs, or even data as an array
or hash or hash of hashes, etc.

We will see how to do all three of these things in the following lab...

1. Classify a node with Hiera
2. Pass class params to a class with Hiera (automatic class parameter lookup)
3. Define and use arbitrary data in Hiera

But first we need to configure Puppet to use Hiera...

### The Hiera Config File ###

Puppet knows about Hiera, and you'll see in a bit that there are some hiera
function calls we can use in our puppet code to search our Hiera data.  But
first, we need to configure the main Hiera config file:

```
     [root@puppet ~]# puppet config print hiera_config
     /etc/puppetlabs/puppet/hiera.yaml
```

Puppet comes with an example **hiera.yaml** as follows:

```
     [root@puppet ~]# cd /etc/puppetlabs/puppet
     [root@puppet puppet]# cat hiera.yaml
     ---
     :backends:
       - yaml

     :hierarchy:
       - defaults
       - "%{clientcert}"
       - "%{environment}"
       - global

     :yaml:
     # datadir is empty here, so hiera uses its defaults:
     # - /var/lib/hiera on *nix
     # - %CommonAppData%\PuppetLabs\hiera\var on Windows
     # When specifying a datadir, make sure the directory exists.
       :datadir:
```

In addition to the **'yaml'** backend option, you can use **'json'** if you like.
See Also:  [Hiera Data Sources](https://docs.puppetlabs.com/hiera/1/data_sources.html#yaml)

The **hiera.yaml** provided is actually fully usable as-is except for that lack of **datadir** definition.  Let's define that, and make some other minor changes as follows:

1. Change 'global' to 'common' ... just my own personal preference
2. Delete 'defaults' and '%{environment}' as we wont use them
3. Tweak the **clientcert** line to look for the yaml in a **node/** directory
4. Set the **datadir** to the `%{environment}/data` directory as we will eventually have multiple environments
5. Lets also add a couple other levels to our hierarchy for **role** and **location**

That should be good to get us started looking at how Hiera can be used...so our hiera.yaml
will look like this:

```
[root@puppet puppet]# cp hiera.yaml hiera.yaml.orig
[root@puppet puppet]# vi hiera.yaml
[root@puppet puppet]# cat hiera.yaml
---
:backends:
  - yaml

:hierarchy:
  - "node/%{clientcert}"
  - "role/%{role}"
  - "location/%{location}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/puppet/environments/%{environment}/data"
```

Go ahead and edit your hiera.yaml if you haven't already.


### There's just one hiera.yaml ###

Notice that there is just one **hiera.yaml** for all of our puppet environments,
**NOT** separate hiera.yaml files per-environment.  This is important to
realize, because in a later lab we will move our hiera.yaml under Git control,
and it will be sitting within the production environment.  This could become
confusing as we branch off other environments, which would also contain
the hiera.yaml.  We might be tempted to edit the hiera.yaml differently in
each environment, but this will not work as expected.  Puppet will always
look for the hiera.yaml where the **hiera_config** tells it to look--it's
not a dynamically-evaluated config parameter, so you can't include a variable
in the config and expect puppet to re-evaluate that config item every run.
Remember that we have to re-start Puppet after editing the hiera.yaml? So we
shouldn't expect puppet to automatically re-read different versions of the
hiera.yaml every time it runs.  Let's **test this** later to verify that this
is indeed the case.  For now don't worry about it... just remember that there's
just one hiera.yaml, and the same one is used by every puppet run reguardless
of the environment.

**Key Points:**

- Puppet uses just one hiera.yaml for all environments
- Each environment **can** have its own unique Hiera Data



### Setup the Hiera Data directory(s) ###

We've configured our hiera.yaml, but we still need to create the **datadir** as
we've defined it within the hiera.yaml.  This is where Hiera will look for
data when we make use of any of the hiera functions calls within our puppet code.

Make sure you're still sitting in **/etc/puppetlabs/puppet** and make the following directories:

```
     [root@puppet puppet]# mkdir environments/production/data
     [root@puppet puppet]# mkdir environments/production/data/node
     [root@puppet puppet]# mkdir environments/production/data/role
     [root@puppet puppet]# mkdir environments/production/data/location
     [root@puppet puppet]# tree environments
     environments
     └── production
         ├── data
         │   ├── location
         │   ├── node
         │   └── role
         ├── manifests
         │   ├── common_hosts.pp
         │   ├── common_packages.pp
         │   └── site.pp
         └── modules
     [snip]

```

### Update the puppet.conf to know about the hiera.yaml ###

Even though the default value for **hiera_config** is correct, let's put it
in the puppet.conf **[main]** section just to have it explicitely defined.
This makes it more obvious to someone how puppet knows to read the hiera.yaml
in that location.  So the [main] section of your puppet.conf (on the Puppet
Master) should look like this (I've only added one new line for **hiera_config**
and the rest of these options should have already been there):

```ini
     [master]
     node_terminus = classifier
     reports = console,puppetdb
     storeconfigs = true
     storeconfigs_backend = puppetdb
     certname = puppet.example.com
     always_cache_features = true
     hiera_config = /etc/puppetlabs/puppet/hiera.yaml
```

Again, this is the default, but we will change the location of the hiera.yaml
in a later lab (when we move our code under Git control) so let's get the default
in there now, so later on when we change it we can easily see what we're changing
it **from** and changing it **to**.

### Restart the Puppet Master ###

After making any changes to the **puppet.conf** and/or the **hiera.yaml**,
you must **re-start** the Puppet Master so that it re-reads those config files.

Each time you run puppet from the command line, it will re-read the puppet.conf,
but keep in mind that the Puppet Master reads it too, and it's running daemonized
in the background.  This is why we need to restart the service so that the
Puppet Master re-reads the [main] and [master] sections of the puppet.conf.

Same deal for the hiera.yaml.  Even though you can run hiera from the command
line to test data lookups, and it re-reads the hiera.yaml each time, the Puppet
Master does not.  It reads it only once when it starts, and keeps that snapshot
of the config it memory for fast access.


If you're on CentOS/RHEL6:

```
     service pe-puppetserver restart
```

Or if you're on CentOS/RHEL7:

```
     systemctl restart pe-puppetserver
```


### So are we ready to use Hiera yet? ###

**Yes!**   Here's what we've done to get to this point:

1. Created a **hiera.yaml**
2. Created a **data/** directory within the existing production environment directory
3. Created a few hiera data sub-directories to align with our hiera.yaml
4. Updated the **puppet.conf** with the **hiera_config** option and value
5. **Restarted** the Puppet Master to that it would re-read the puppet.conf and hiera.yaml

### Using Hiera in your Puppet Code ###

Again, there are 3 ways we can use Hiera:

1. Classify a node
2. Pass class params in to a class (also called automatic parameter lookup)
3. Define and use arbitrary data as puppet variables

Let's start looking at the first one:  Classify a node

### Node Classification with Hiera ###

Instead of using node definitions in the **site.pp**, let's use the Hiera
function call **hiera_include('classes')** as follows...

```puppet
    hiera_include('classes')
```

We can simply add that one line to the end of our site.pp and Puppet will search
through every level of our Hiera data for the **key** with the name **classes**
then take the **value** and append it on a list of classes.  The end result will
be a list of classes to apply to the node.

Although node definitions could still be used, the power of Hiera is that you can
have puppet search a hierarchy of yaml files looking for a set of classes to be
applied on a per-node basis, as well as many other levels (or groupings).  For
example, you could specify a particular class be declared for all Linux systems,
or all Solaris systems, or all systems at a particular location, or that are a part
of a particular department.  The call to hiera_include('classes') will build up
a list of classes to apply for a node, but it can assemble this list of classes from
all levels throughout your hierarchy if you've declared classes at multiple levels.

With your Hiera config (hiera.yaml) already setup, you'd need to put somewhere within
your hierarchy a yaml file containing such as the following:

```yaml
---
    classes:
      - some_cool_class
      - some_other_class
      - and_yet_another_class

```

This would cause these classes to be declared for whatever **level** in the hierarchy
they have been specified.  For example, if you put the above in a **"node-level yaml"** file,
they would get declared for the corresponding node.  If you put it in a yaml file
for a specific **OS Family**, they would get declared only for systems running that particular OS Family.
Etc.  Notice in the first case the classes would be applied to one specific node, while in the
second case the classes could be be applied to a set of nodes.


## Hiera Examples ##

Let's work through an example to get a better understanding how all of this works.

Here's the overview of what we are about to do:

1. Install the ntp module
2. Create a "node-level" yaml file for the **agent** node and assign the **ntp** class to it
3. Create a **common.yaml** and put in NTP server parameters to illistrate the **[auto-parameter lookup](https://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup)** feature of Hiera
4. Show how we can define multiple locations, and override the NTP servers for each location
5. Start to talk about facter just a little bit, and show how we can set the location in two ways: a Hiera key or a Fact on the agent side and explain the security implications
   (Facts come from the agent/node side, while Hiera data is only on the Master)

Now, follow along as we walk through each step...

On our Puppet Master, the end of the **site.pp** looks like this:

```puppet
#
# Global - All code outside a node definition gets applied to all nodes
#

include common_packages
include common_hosts

#
# Node-specific
#

node 'puppet.example.com' {
}

node 'agent.example.com' {
}

#
# Default - if no other Node-specific definition matched
#

node default {
}
```


Let's **delete** the node definitions for 'puppet.example.com' and 'agent.example.com'...They're not even used anyway.  And then let's add our call to **hiera_include**

(Remember, the **site.pp** is in `/etc/puppetlabs/puppet/environments/production/manifests/` )

We want the end of our site.pp to end up looking like this:

```puppet
#
# Global - All code outside a node definition gets applied to all nodes
#

include common_packages
include common_hosts

#
# Default - Not used, but Puppet requires at least an empty **node default**
#

node default {
}

#
# Use Hiera to classify nodes
#

hiera_include('classes')

```


Go ahead and try running puppet on the Puppet Master now, and see what happens...


```shell
     [root@puppet ~]# cd /etc/puppetlabs/puppet/environments/production/manifests/
     [root@puppet manifests]# vi site.pp
     [root@puppet manifests]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Error: Could not retrieve catalog from remote server: Error 400 on SERVER: Could
          not find data item classes in any Hiera data file and no default supplied at
          /etc/puppetlabs/puppet/environments/production/manifests/site.pp:53
          on node puppet.example.com
     Warning: Not using cache on failed catalog
     Error: Could not retrieve catalog; skipping run
```

Notice that Puppet couldn't find the key **"classes"** anywhere within our Hiera data hierarchy.
That is to be expected!  We told Hiera to look for the key **classes** in our Hiera Data, but
we have not created any Hiera Data yet!

```shell
     [root@puppet manifests]# pwd
     /etc/puppetlabs/puppet/environments/production/manifests
     [root@puppet manifests]# cd ../data
     [root@puppet data]# vi common.yaml
```


Let's add the following to the **common.yaml**:


```yaml
---

classes:
   - common_hosts
   - common_packages

```

Try running puppet again...and you should get a clean run.

Did you notice that we already had the **common_hosts** and **common_packages**
declared via an include in the site.pp?  Now that we've put those in the common.yaml,
we can remove them from the site.pp, as they're not needed in both places.

Go ahead and edit your site.pp and remove them, so you're left with...


```puppet
#
# Global - All code outside a node definition gets applied to all nodes
#

#
# Default - if no other Node-specific definition matched
#

node default {
}

hiera_include('classes')
```

Now run puppet again, and you should notice no changes at all.  Good?

So all we've done is configured Hiera and used it as a pseudo-ENC, created our first hiera data file **common.yaml** and changed the way we are declaring the 'common_hosts' and 'common_packages' classes.








# The following example only works on a full VM, not in a Docker container #
# Need to come up with a different example that works in both a VM and Docker Container #

**Next**, let's install a module, and show how we can declare that class on only the agent node using a "node-level" yaml file.


```shell
     [root@puppet manifests]# puppet module install puppetlabs/ntp
     Notice: Preparing to install into /etc/puppetlabs/puppet/environments/production/modules ...
     Notice: Downloading from https://forgeapi.puppetlabs.com ...
     Notice: Installing -- do not interrupt ...
     /etc/puppetlabs/puppet/environments/production/modules
     └─┬ puppetlabs-ntp (v4.2.0)
       └── puppetlabs-stdlib (v4.12.0)
```


We now have the PuppetLab's NTP module installed.

Next, let's tell Puppet to declare this class for node **agent.example.com**


```shell
     [root@puppet production]# pwd
     /etc/puppetlabs/puppet/environments/production
     [root@puppet production]# cd data
     [root@puppet data]# tree
     .
     ├── common.yaml
     ├── location
     ├── node
     └── role

     3 directories, 1 file
     [root@puppet data]# cd node
     [root@puppet node]# vi agent.example.com.yaml
```


Add the following in to the **agent.example.com.yaml**


```yaml
---

classes:
   - ntp


```


Now on **agent.example.com** run puppet, and you should see Puppet configure NTP on that node only.


```shell
     [root@agent ~]# puppet agent -t
     Info: Retrieving pluginfacts
     [snip] - removed all the output from the pluginfacts download
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1457048266'
     Notice: /Stage[main]/Ntp::Install/Package[ntp]/ensure: created
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content:
     --- /etc/ntp.conf 2016-01-25 14:15:26.000000000 +0000
     +++ /tmp/puppet-file20160303-5563-1bz48di 2016-03-03 23:38:23.047844481 +0000
     @@ -1,58 +1,36 @@
     -# For more information about this file, see the man pages
     -# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).
     +# ntp.conf: Managed by puppet.
     +#
     +# Enable next tinker options:
     +# panic - keep ntpd from panicking in the event of a large clock skew
     +# when a VM guest is suspended and resumed;
     +# stepout - allow ntpd change offset faster
     +tinker panic 0

     -driftfile /var/lib/ntp/drift
     +disable monitor

      # Permit time synchronization with our time source, but do not
      # permit the source to query or modify the service on this system.
     -restrict default nomodify notrap nopeer noquery
     +restrict default kod nomodify notrap nopeer noquery
     +restrict -6 default kod nomodify notrap nopeer noquery
     +restrict 127.0.0.1
     +restrict -6 ::1
     +
     +
     +
     +# Set up servers for ntpd with next options:
     +# server - IP address or DNS name of upstream NTP server
     +# iburst - allow send sync packages faster if upstream unavailable
     +# prefer - select preferrable server
     +# minpoll - set minimal update frequency
     +# maxpoll - set maximal update frequency
     +server 0.centos.pool.ntp.org
     +server 1.centos.pool.ntp.org
     +server 2.centos.pool.ntp.org
     +
     +
     +# Driftfile.
     +driftfile /var/lib/ntp/drift
     +
     +
     +

     -# Permit all access over the loopback interface.  This could
     -# be tightened as well, but to do so would effect some of
     -# the administrative functions.
     -restrict 127.0.0.1
     -restrict ::1
     -
     -# Hosts on local network are less restricted.
     -#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
     -
     -# Use public servers from the pool.ntp.org project.
     -# Please consider joining the pool (http://www.pool.ntp.org/join.html).
     -server 0.centos.pool.ntp.org iburst
     -server 1.centos.pool.ntp.org iburst
     -server 2.centos.pool.ntp.org iburst
     -server 3.centos.pool.ntp.org iburst
     -
     -#broadcast 192.168.1.255 autokey # broadcast server
     -#broadcastclient     # broadcast client
     -#broadcast 224.0.1.1 autokey   # multicast server
     -#multicastclient 224.0.1.1   # multicast client
     -#manycastserver 239.255.254.254    # manycast server
     -#manycastclient 239.255.254.254 autokey # manycast client
     -
     -# Enable public key cryptography.
     -#crypto
     -
     -includefile /etc/ntp/crypto/pw
     -
     -# Key file containing the keys and key identifiers used when operating
     -# with symmetric key cryptography.
     -keys /etc/ntp/keys
     -
     -# Specify the key identifiers which are trusted.
     -#trustedkey 4 8 42
     -
     -# Specify the key identifier to use with the ntpdc utility.
     -#requestkey 8
     -
     -# Specify the key identifier to use with the ntpq utility.
     -#controlkey 8
     -
     -# Enable writing of statistics records.
     -#statistics clockstats cryptostats loopstats peerstats
     -
     -# Disable the monitoring facility to prevent amplification attacks using ntpdc
     -# monlist command when default restrict does not include the noquery flag. See
     -# CVE-2013-5211 for more details.
     -# Note: Monitoring will not be disabled with the limited restriction flag.
     -disable monitor

     Info: Computing checksum on file /etc/ntp.conf
     Info: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]: Filebucketed /etc/ntp.conf to main with sum dc9e5754ad2bb6f6c32b954c04431d0a
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}dc9e5754ad2bb6f6c32b954c04431d0a' to '{md5}c1d0e073779a9102773754cf972486be'
     Info: Class[Ntp::Config]: Scheduling refresh of Class[Ntp::Service]
     Info: Class[Ntp::Service]: Scheduling refresh of Service[ntp]
     Notice: /Stage[main]/Ntp::Service/Service[ntp]/ensure: ensure changed 'stopped' to 'running'
     Info: /Stage[main]/Ntp::Service/Service[ntp]: Unscheduling refresh on Service[ntp]
     Notice: Finished catalog run in 35.90 seconds
```

In the above output, where the ntp.conf edit is shown, any line with a minus sign in front is being removed by puppet, and any line with a plus sign in front is being added. (Similar to what you would see when use use the **diff** command)

Notice that Puppet did a few things:

1. It installed the NTP package
2. It configured the /etc/ntp.conf
3. It enabled and started the NTP service

Notice that if you use **puppet resource** to check the current state of the ntpd it shows it's running and enabled:

```puppet
     [root@agent ~]# puppet resource service ntpd
     service { 'ntpd':
       ensure => 'running',
       enable => 'true',
     }
```

Has our time sync'ed yet?

```
     [root@agent ~]# date
     Thu Mar  3 23:52:53 UTC 2016
     [root@agent ~]# timedatectl
           Local time: Thu 2016-03-03 23:52:55 UTC
       Universal time: Thu 2016-03-03 23:52:55 UTC
             RTC time: Thu 2016-03-03 23:52:54
            Time zone: UTC (UTC, +0000)
          NTP enabled: yes
     NTP synchronized: no
      RTC in local TZ: no
           DST active: n/a
```

However, NTP isn't sync'ing, and I can't tell what time it really is because the timezone is set to UTC
How about we install a puppet module to manage the timezone for us?

I found the saz-timezone module on the Puppet Forge ( <http://forge.puppetlabs.com/> )
and even though it's not a puppetlabs-authored module, nor a puppetlabs-supported module,
it does seem to be the most popular, and has a good user rating.  It also supports
pretty much any/all linux flavor out there.  (Always make sure to check that
the module you're installing supports the platforms you will be using, or forsee
yourself using in the future.)

Let's go ahead and install the saz-timezone module...

```shell
     [root@puppet node]# puppet module install saz-timezone
     Notice: Preparing to install into /etc/puppetlabs/puppet/environments/production/modules ...
     Notice: Downloading from https://forgeapi.puppetlabs.com ...
     Notice: Installing -- do not interrupt ...
     /etc/puppetlabs/puppet/environments/production/modules
     └─┬ saz-timezone (v3.3.0)
       └── puppetlabs-stdlib (v4.11.0)
```

### Hiera auto-parameter lookup ###

Next, edit your node yaml for **"agent.example.com"** again, add the new class, and add the class parameter we'd like to pass in:

```yaml
---

classes:
   - ntp
   - timezone

timezone::timezone: 'US/Pacific'

```

Notice that funny **timezone::timezone** line in there.  This is the second
way we can use Hiera.  When we put in a line of the form  **CLASS**::**PARAM**: **VALUE**
Puppet will automatically look for and find the value for that parameter.
This is a nice way to keep your site-specific data separated out from your code/modules.


```shell
     [root@agent ~]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1457049735'
     Notice: /Stage[main]/Timezone/File[/etc/localtime]/target: target changed '../usr/share/zoneinfo/UTC' to '/usr/share/zoneinfo/US/Pacific'
     Notice: Finished catalog run in 0.65 seconds

     [root@agent ~]# date
     Thu Mar  3 16:02:26 PST 2016

     [root@agent ~]# timedatectl
           Local time: Thu 2016-03-03 16:02:35 PST
       Universal time: Fri 2016-03-04 00:02:35 UTC
             RTC time: Fri 2016-03-04 00:02:35
            Time zone: US/Pacific (PST, -0800)
          NTP enabled: yes
     NTP synchronized: yes
      RTC in local TZ: no
           DST active: no
      Last DST change: DST ended at
                       Sun 2015-11-01 01:59:59 PDT
                       Sun 2015-11-01 01:00:00 PST
      Next DST change: DST begins (the clock jumps one hour forward) at
                       Sun 2016-03-13 01:59:59 PST
                       Sun 2016-03-13 03:00:00 PDT

```

Okay, that looks better.  Time date/time is correct, timezone has been set, and NTP is sync'ed.

Notice that we're pointing at the following NTP servers:

```
     [vagrant@agent ~]$ grep 'server ' /etc/ntp.conf
     # server - IP address or DNS name of upstream NTP server
     server 0.centos.pool.ntp.org
     server 1.centos.pool.ntp.org
     server 2.centos.pool.ntp.org
```

What if we have our own internal NTP servers that we'd prefer to point at?  Or maybe we just wanted to change to use a different set of external NTP servers?

Let's add the appropriate class params in our hiera data to set the NTP servers to the following:

```
     server 0.pool.ntp.org
     server 1.pool.ntp.org
     server 2.pool.ntp.org
     server 3.pool.ntp.org
```

Well how would we know what class and param name to use?  You can do one of the following:

1. Read the documentation for the module at:   <https://forge.puppetlabs.com/puppetlabs/ntp>
2. Click on [Project URL]<https://github.com/puppetlabs/puppetlabs-ntp/tree/master/manifests> link at the top of the Puppet Forge page for the module, and then read the actual puppet code.
3. Find the module on your Puppet Master, and browse the code there.

Hopefully the module is well documented.  In the case of puppetlab-ntp, it is very well documented, and says to specify the servers like this:

```puppet
     class { '::ntp':
       servers => [ '0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org' ],
     }
```

That is a special syntax (which we've not seen yet) for declaring a class and
passing parameters in.  This is not how we do it with Hiera, but at least we
can see the name of the class is just **'ntp'** and the parameter name is
**'servers'** and expects an array of server names.

The Hiera data to specify this would look like this:

```yaml

     ntp::servers:
       - '0.pool.ntp.org'
       - '1.pool.ntp.org'
       - '2.pool.ntp.org'
       - '3.pool.ntp.org'

```

Let's add this to our **common.yaml** with the idea being we'd want these NTP servers set for any and every node using the ntp module.

Run puppet on your training agent, and you'll notice that puppet updated your /etc/ntp.conf as well as restarted ntpd:

```shell
     [root@agent ~]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1457113052'
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content:
     --- /etc/ntp.conf 2016-03-03 15:38:23.224932992 -0800
     +++ /tmp/puppet-file20160304-5786-a8sfia  2016-03-04 09:37:35.936738602 -0800
     @@ -23,9 +23,10 @@
      # prefer - select preferrable server
      # minpoll - set minimal update frequency
      # maxpoll - set maximal update frequency
     -server 0.centos.pool.ntp.org
     -server 1.centos.pool.ntp.org
     -server 2.centos.pool.ntp.org
     +server 0.pool.ntp.org
     +server 1.pool.ntp.org
     +server 2.pool.ntp.org
     +server 3.pool.ntp.org


      # Driftfile.

     Info: Computing checksum on file /etc/ntp.conf
     Info: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]: Filebucketed /etc/ntp.conf to main with sum c1d0e073779a9102773754cf972486be
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}c1d0e073779a9102773754cf972486be' to '{md5}e2536ee231371aacd1d7020d863147c2'
     Info: Class[Ntp::Config]: Scheduling refresh of Class[Ntp::Service]
     Info: Class[Ntp::Service]: Scheduling refresh of Service[ntp]
     Notice: /Stage[main]/Ntp::Service/Service[ntp]: Triggered 'refresh' from 1 events
     Notice: Finished catalog run in 0.83 seconds
```

If you run puppet on your master, you'll notice that puppet doesn't make any changes...

```shell
     [root@puppet data]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1457113038'
     Notice: Finished catalog run in 5.82 seconds
```

...that because we've not configured the Puppet Master to use the NTP module.
The thing to notice here is that we can define class parameters at the "common level"
even if only a subset of our nodes will query for them.  It's just data sitting out
there in Hiera, and puppet will query it when needed, but it doesnt' hurt to be
there for nodes that arn't using those parameters.  Make sense?

Next, let's enable the NTP module on our Puppet Master **puppet.example.com**.  To
do this, we will create a "node-level" YAML file, and then add the class to the
array of classes under the **classes** key.

Get into the right directory, and create your yaml file as follows...

```shell
     [root@puppet ~]# cd /etc/puppetlabs/puppet/environments/production/data/node/
     [root@puppet node]# vi puppet.example.com.yaml
```

Then put the following in your YAML file...

```yaml
---

classes:
  - ntp

```

Now, run **puppet agent -t** and see what happens...

```shell
     [root@puppet node]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1457373850'
     Notice: /Stage[main]/Ntp::Install/Package[ntp]/ensure: created
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content:
     --- /etc/ntp.conf 2016-01-25 14:15:26.000000000 +0000
     +++ /tmp/puppet-file20160307-10431-1q5565m  2016-03-07 18:04:29.771580255 +0000
     @@ -1,58 +1,37 @@
     -# For more information about this file, see the man pages
     -# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).
     +# ntp.conf: Managed by puppet.
     +#
     +# Enable next tinker options:
     +# panic - keep ntpd from panicking in the event of a large clock skew
     +# when a VM guest is suspended and resumed;
     +# stepout - allow ntpd change offset faster
     +tinker panic 0

     -driftfile /var/lib/ntp/drift
     +disable monitor

      # Permit time synchronization with our time source, but do not
      # permit the source to query or modify the service on this system.
     -restrict default nomodify notrap nopeer noquery
     +restrict default kod nomodify notrap nopeer noquery
     +restrict -6 default kod nomodify notrap nopeer noquery
     +restrict 127.0.0.1
     +restrict -6 ::1
     +
     +
     +
     +# Set up servers for ntpd with next options:
     +# server - IP address or DNS name of upstream NTP server
     +# iburst - allow send sync packages faster if upstream unavailable
     +# prefer - select preferrable server
     +# minpoll - set minimal update frequency
     +# maxpoll - set maximal update frequency
     +server 0.pool.ntp.org
     +server 1.pool.ntp.org
     +server 2.pool.ntp.org
     +server 3.pool.ntp.org
     +
     +
     +# Driftfile.
     +driftfile /var/lib/ntp/drift
     +
     +
     +

     -# Permit all access over the loopback interface.  This could
     -# be tightened as well, but to do so would effect some of
     -# the administrative functions.
     -restrict 127.0.0.1
     -restrict ::1
     -
     -# Hosts on local network are less restricted.
     -#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
     -
     -# Use public servers from the pool.ntp.org project.
     -# Please consider joining the pool (http://www.pool.ntp.org/join.html).
     -server 0.centos.pool.ntp.org iburst
     -server 1.centos.pool.ntp.org iburst
     -server 2.centos.pool.ntp.org iburst
     -server 3.centos.pool.ntp.org iburst
     -
     -#broadcast 192.168.1.255 autokey # broadcast server
     -#broadcastclient     # broadcast client
     -#broadcast 224.0.1.1 autokey   # multicast server
     -#multicastclient 224.0.1.1   # multicast client
     -#manycastserver 239.255.254.254    # manycast server
     -#manycastclient 239.255.254.254 autokey # manycast client
     -
     -# Enable public key cryptography.
     -#crypto
     -
     -includefile /etc/ntp/crypto/pw
     -
     -# Key file containing the keys and key identifiers used when operating
     -# with symmetric key cryptography.
     -keys /etc/ntp/keys
     -
     -# Specify the key identifiers which are trusted.
     -#trustedkey 4 8 42
     -
     -# Specify the key identifier to use with the ntpdc utility.
     -#requestkey 8
     -
     -# Specify the key identifier to use with the ntpq utility.
     -#controlkey 8
     -
     -# Enable writing of statistics records.
     -#statistics clockstats cryptostats loopstats peerstats
     -
     -# Disable the monitoring facility to prevent amplification attacks using ntpdc
     -# monlist command when default restrict does not include the noquery flag. See
     -# CVE-2013-5211 for more details.
     -# Note: Monitoring will not be disabled with the limited restriction flag.
     -disable monitor

     Info: Computing checksum on file /etc/ntp.conf
     Info: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]: Filebucketed /etc/ntp.conf to main with sum dc9e5754ad2bb6f6c32b954c04431d0a
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}dc9e5754ad2bb6f6c32b954c04431d0a' to '{md5}e2536ee231371aacd1d7020d863147c2'
     Info: Class[Ntp::Config]: Scheduling refresh of Class[Ntp::Service]
     Info: Class[Ntp::Service]: Scheduling refresh of Service[ntp]
     Notice: /Stage[main]/Ntp::Service/Service[ntp]/ensure: ensure changed 'stopped' to 'running'
     Info: /Stage[main]/Ntp::Service/Service[ntp]: Unscheduling refresh on Service[ntp]
     Notice: Finished catalog run in 10.84 seconds

```

NTP has been configured, enabled, and started on the Puppet Master.

```shell
     [root@puppet node]# timedatectl
           Local time: Mon 2016-03-07 18:06:30 UTC
       Universal time: Mon 2016-03-07 18:06:30 UTC
             RTC time: Mon 2016-03-07 18:06:30
            Time zone: UTC (UTC, +0000)
          NTP enabled: yes
     NTP synchronized: yes
      RTC in local TZ: no
           DST active: n/a
```

Oh, we forgot to set the timezone.  Let's do that now.  Add the **timezone** class to the array of classes (causing that class to be declared for the puppet.example.com node) and also set the timezone parameter to 'US/Pacific' as follows...

```yaml
---

classes:
  - ntp
  - timezone

timezone::timezone: 'US/Pacific'

```

Okay, that looks better...

```shell
     [root@puppet node]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1457374071'
     Notice: /Stage[main]/Timezone/File[/etc/localtime]/target: target changed '../usr/share/zoneinfo/UTC' to '/usr/share/zoneinfo/US/Pacific'
     Notice: Finished catalog run in 5.37 seconds

     [root@puppet node]# timedatectl
           Local time: Mon 2016-03-07 10:09:00 PST
       Universal time: Mon 2016-03-07 18:09:00 UTC
             RTC time: Mon 2016-03-07 18:09:01
            Time zone: US/Pacific (PST, -0800)
          NTP enabled: yes
     NTP synchronized: yes
      RTC in local TZ: no
           DST active: no
      Last DST change: DST ended at
                       Sun 2015-11-01 01:59:59 PDT
                       Sun 2015-11-01 01:00:00 PST
      Next DST change: DST begins (the clock jumps one hour forward) at
                       Sun 2016-03-13 01:59:59 PST
                       Sun 2016-03-13 03:00:00 PDT
```

Okay, Let's summarize what we've done so far...

1. Enabled the use of Hiera as a pseudo-ENC with **hiera_include('classes')** in our site.pp
2. Installed two modules on our Puppet Master:  **puppetlabs-ntp** and **saz-timezone**
3. Created a **common.yaml** and declared the **common_hosts** and **common_packages** classes
4. Created a **"node-level"** YAML file for both **agent.example.com** and **puppet.example.com**
5. Declared the **ntp** and **timezone** modules for both **agent.example.com** and **puppet.example.com**
6. We also configured the list of ntp servers and the timezone in the common.yaml using auto-parameter lookup

Our Hiera data YAML files look like this:

```shell
     [root@puppet data]# pwd
     /etc/puppetlabs/puppet/environments/production/data
     [root@puppet data]# tree
     .
     ├── common.yaml
     ├── location
     ├── node
     │   ├── agent.example.com.yaml
     │   └── puppet.example.com.yaml
     └── role

     3 directories, 3 files
     [root@puppet data]# cat common.yaml
```

```yaml
---

classes:
   - common_hosts
   - common_packages

ntp::servers:
  - '0.pool.ntp.org'
  - '1.pool.ntp.org'
  - '2.pool.ntp.org'
  - '3.pool.ntp.org'
```

```shell
     [root@puppet data]# cat node/puppet.example.com.yaml
```

```yaml
---

classes:
   - ntp
   - timezone

timezone::timezone: 'US/Pacific'
```

```shell
     [root@puppet data]# cat node/agent.example.com.yaml
```

```yaml
---

classes:
   - ntp
   - timezone

timezone::timezone: 'US/Pacific'
```

### Important Note about Hiera Lookups ###

So far we've looked at two ways Hiera can be used:

1.  to classify nodes with the **hiera_include('classes')** function call
2.  to provide class parameter values through Hiera's auto-parameter lookup functionality

It is critically important to understand that these two Hiera features work
differently on the hierarchy of data

The **hiera_include('classes')** function searches **all** hiera data at
**every level** for the key **"classes"** and builds an array of classes.
So you can specify **classes** at the node level or common level and/or every
level in-between, and the hiera_include function will pickup them all.

Hiera behaves differently for auto-parameter lookup, as well as arbitrary data
lookup function **hiera()** which we are about to look at in the next section.

When looking up class parameters, Hiera searches through your hierarcy of
data from the **top down** (as each data source appears in the hiera.yaml)
and takes the first occurance of the parameter found.  In other words,
Hiera takes the **most specific** paramater value, with the understanding
that the top level (**node level**) is the most specific, and every level
below that a less and less specific level until you reach the bottom
level **common**.

Knowing this, you may specify the same class parameter value at a higher
level to override the value set at a lower level.

For example, if you have the timezone set to 'US/Pacific' in the common.yaml,
but want to override this value for a particular node, you can specify that
same parameter in the node-level yaml file as a different value, and Hiera
will use it instead, because Hiera will encounter it first in its search
for the value.

The same behavior is followed for the **hiera()** lookup function we will
cover in the following section...


### Hiera lookup functions for arbitrary data ###

The third way we can use Hiera is to lookup arbitrary data in our hierarchy.
We can define key/value pairs within our hierarchy and then use the hiera
lookup functions to query the value(s) within our puppet code.

The **hiera()** function behaves the same way as auto-parameter lookup.
It gets the most specific value for a given key. It can retrieve values
of any data type including strings, arrays, or hashes, or even multi-level
data structures, such as hashes of strings, or arrays of hashes, etc.

One use case for this that I've seen in the wild is to store certain bits
of static data about a node in Hiera, rather than rely on a agent-side custom
defined fact.

### Facter ###

But what is a fact?  We haven't talked about what a **"fact"** is yet, so let's
take this opportunity to introduce **facter** and than show two ways that we
can cause puppet to **known** certain facts about a agent/node.

Facter presents many common system parameters to you as top-scope puppet
variables.  It provides a common namespace for many useful facts across all
platforms so you can reference the same fact in your code without worrying
what the platform is where the agent is running.

You can use the **facter** command to see the facts on an agent node
by simply running **facter** without any arguments.   You can tell facter
to include some extra puppet-specific facts with the **-p** option:

```
     [root@puppet data]# facter -p
     architecture => x86_64
     augeasversion => 1.3.0
     bios_release_date => 12/01/2006
     bios_vendor => innotek GmbH
     bios_version => VirtualBox
     blockdevice_sda_model => VBOX HARDDISK
     blockdevice_sda_size => 21474836480
     blockdevice_sda_vendor => ATA
     blockdevices => sda
     boardmanufacturer => Oracle Corporation
     boardproductname => VirtualBox
     boardserialnumber => 0
     custom_auth_conf => false
     dhcp_servers => {"system"=>"10.0.2.2", "enp0s3"=>"10.0.2.2"}
     domain => example.com
     facterversion => 2.4.4
     filesystems => xfs
     fqdn => puppet.example.com
     gid => root
     hardwareisa => x86_64
     hardwaremodel => x86_64
     hostname => puppet
     id => root
     interfaces => enp0s3,enp0s8,lo
     ipaddress => 10.0.2.15
     ipaddress_enp0s3 => 10.0.2.15
     ipaddress_enp0s8 => 192.168.198.10
     ipaddress_lo => 127.0.0.1
     is_pe => true
     is_virtual => true
     kernel => Linux
     kernelmajversion => 3.10
     kernelrelease => 3.10.0-327.10.1.el7.x86_64
     kernelversion => 3.10.0
     macaddress => 08:00:27:39:18:3c
     macaddress_enp0s3 => 08:00:27:39:18:3c
     macaddress_enp0s8 => 08:00:27:60:30:a5
     manufacturer => innotek GmbH
     memoryfree => 625.75 MB
     memoryfree_mb => 625.75
     memorysize => 3.70 GB
     memorysize_mb => 3791.46
     mtu_enp0s3 => 1500
     mtu_enp0s8 => 1500
     mtu_lo => 65536
     netmask => 255.255.255.0
     netmask_enp0s3 => 255.255.255.0
     netmask_enp0s8 => 255.255.255.0
     netmask_lo => 255.0.0.0
     network_enp0s3 => 10.0.2.0
     network_enp0s8 => 192.168.198.0
     network_lo => 127.0.0.0
     operatingsystem => CentOS
     operatingsystemmajrelease => 7
     operatingsystemrelease => 7.2.1511
     os => {"name"=>"CentOS", "family"=>"RedHat", "release"=>{"major"=>"7", "minor"=>"2", "full"=>"7.2.1511"}}
     osfamily => RedHat
     package_provider => yum
     partitions => {"sda1"=>{"uuid"=>"39ce4ad1-4e9d-49a4-bce0-8a30b459490a", "size"=>"1024000", "mount"=>"/boot", "filesystem"=>"xfs"}, "sda2"=>{"size"=>"40916992", "filesystem"=>"LVM2_member"}}
     path => /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
     pe_build => 3.8.4
     pe_concat_basedir => /var/opt/lib/pe-puppet/pe_concat
     pe_major_version => 3
     pe_minor_version => 8
     pe_patch_version => 4
     pe_version => 3.8.4
     physicalprocessorcount => 1
     platform_symlink_writable => true
     platform_tag => el-7-x86_64
     processor0 => Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz
     processor1 => Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz
     processor2 => Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz
     processor3 => Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz
     processorcount => 4
     processors => {"models"=>["Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz", "Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz", "Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz", "Intel(R) Core(TM) i7-2720QM CPU @ 2.20GHz"], "count"=>4, "physicalcount"=>1}
     productname => VirtualBox
     ps => ps -ef
     puppet_vardir => /var/opt/lib/pe-puppet
     puppetversion => 3.8.5 (Puppet Enterprise 3.8.4)
     root_home => /root
     rubyplatform => x86_64-linux
     rubysitedir => /opt/puppet/lib/ruby/site_ruby/1.9.1
     rubyversion => 1.9.3
     selinux => false
     serialnumber => 0
     service_provider => systemd
     staging_http_get => curl
     swapfree => 1.03 GB
     swapfree_mb => 1056.00
     swapsize => 1.03 GB
     swapsize_mb => 1056.00
     system_uptime => {"seconds"=>8362, "hours"=>2, "days"=>0, "uptime"=>"2:19 hours"}
     timezone => PST
     type => Other
     uniqueid => a8c00ac6
     uptime => 2:19 hours
     uptime_days => 0
     uptime_hours => 2
     uptime_seconds => 8362
     uuid => A187A2ED-AF80-4EDB-B3AA-2FA2189320A3
     virtual => virtualbox
```

So if you want to use any of those facts in your puppet code, you can simply take the fact name and use it like you would a top-scope puppet variable like this:

```puppet
     $::fact_name
```

So if you wanted to use the **service_provider** fact, you could reference:

```puppet
     $::service_provider
```

...in your puppet code.  This could be very useful to a module author who wants to support many different OS Families/Platforms.
Take a look at how many possible service providers there are:  [Service Providers](https://docs.puppetlabs.com/puppet/latest/reference/type.html#service-attribute-provider)

What if you want to define a custom fact for use in your puppet code?
Puppet+Facter allows you to write custom code to create a custom fact, but
even simpler, you can also create a yaml file with [static facts](http://docs.puppetlabs.com/facter/2.4/custom_facts.html#external-facts) for that node
that would show up as top-scope puppet variables.

The best way to define custom static agent-side facts is by including them in the facts.d directory within a module.
However, we've not yet learned how to write a module, and to keep things simple for now, let's use the next best
method of creating a yaml file in **/etc/puppetlabs/facter/facts.d/** containing the key/value pair we want to set.

```shell
     [root@agent ~]# mkdir -p /etc/puppetlabs/facter/facts.d

     [root@agent ~]# vi /etc/puppetlabs/facter/facts.d/static-facts.yaml

     [root@agent ~]# cat /etc/puppetlabs/facter/facts.d/static-facts.yaml
     ---
     location: woodinville

     [root@agent ~]# facter location
     woodinville
```

It's as simple as that!  Now, within your puppet code, you could refer to the
top-scope variable **$::location** and you'd get the value **woodinville**.
If you have servers in multiple datacenters in different cities, you could use
such a fact to keep track of where each node/agent is running, and then make
different decisions in your puppet code based on location.  Since facts become
top-scope puppet variables, you can also refer to them in your hiera.yaml!
Remember that we included a **location/${location}** in our hiera.yaml before?
Well, now is our opportunity to use it...

Let's take the time to setup the same custom fact on our Puppet Master as well,
but let's give it a different location of 'seattle' ...

```shell
     [root@puppet data]# mkdir -p /etc/puppetlabs/facter/facts.d

     [root@puppet data]# vi /etc/puppetlabs/facter/facts.d/static-facts.yaml

     [root@puppet data]# cat /etc/puppetlabs/facter/facts.d/static-facts.yaml
     ---
     location: seattle

     [root@puppet data]# facter location
     seattle
```

At this point we have a custom fact called **"location"** setup on both our
**puppet** node and **agent** node, and have tested that facter returns the
correct value from the command line.  Let's try to see if we can access
that variable from within a puppet manifest...

For the sake of simplicity, let's just edit our site.pp, and see if we can
access the location fact as a top-scope puppet variable...Add the single
**notify** resource to the site.pp as follows:

```
     #
     # Global - All code outside a node definition gets applied to all nodes
     #

     notify{ "Location is: ${::location}": }

```

Then run **puppet agent -t** on both the **puppet** node and the **agent** node.

On **puppet.example.com** node we see:

```shell
     [root@puppet manifests]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1457382149'
     Notice: Location is: seattle
     Notice: /Stage[main]/Main/Notify[Location is: seattle]/message: defined 'message' as 'Location is: seattle'
     Notice: Finished catalog run in 5.25 seconds

```

And on **agent.example.com** node we see:

```shell
     [root@agent ~]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1457381961'
     Notice: Location is: woodinville
     Notice: /Stage[main]/Main/Notify[Location is: woodinville]/message: defined 'message' as 'Location is: woodinville'
     Notice: Finished catalog run in 0.49 seconds
```

Now let's take advantage of this new top-scope variable with Hiera.  Create a **woodinville.yaml** and **seattle.yaml** in the data/location directory as follows:

```shell
     [root@puppet puppet]# cd environments/production/data/location/
     [root@puppet location]# vi woodinville.yaml
     [root@puppet location]# cp woodinville.yaml seattle.yaml
```

Let's change the NTP servers we are pointing at to the following:

```yaml
     [root@puppet location]# cat woodinville.yaml
     ---

     ntp::servers:
       - '0.us.pool.ntp.org'
       - '1.us.pool.ntp.org'
       - '2.us.pool.ntp.org'
       - '3.us.pool.ntp.org'

```

(We've just added the **us** in there to use US NTP servers)

Then run puppet, and see what happens...

```
     [root@puppet location]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1457382556'
     Notice: Location is: seattle
     Notice: /Stage[main]/Main/Notify[Location is: seattle]/message: defined 'message' as 'Location is: seattle'
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content:
     --- /etc/ntp.conf 2016-03-07 10:04:29.969580257 -0800
     +++ /tmp/puppet-file20160307-25460-lxcrks 2016-03-07 12:29:29.717938219 -0800
     @@ -23,10 +23,10 @@
      # prefer - select preferrable server
      # minpoll - set minimal update frequency
      # maxpoll - set maximal update frequency
     -server 0.pool.ntp.org
     -server 1.pool.ntp.org
     -server 2.pool.ntp.org
     -server 3.pool.ntp.org
     +server 0.us.pool.ntp.org
     +server 1.us.pool.ntp.org
     +server 2.us.pool.ntp.org
     +server 3.us.pool.ntp.org

      # Driftfile.

     Info: Computing checksum on file /etc/ntp.conf
     Info: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]: Filebucketed /etc/ntp.conf to main with sum e2536ee231371aacd1d7020d863147c2
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}e2536ee231371aacd1d7020d863147c2' to '{md5}568159151d0a076ca61dc5e5c41b989f'
     Info: Class[Ntp::Config]: Scheduling refresh of Class[Ntp::Service]
     Info: Class[Ntp::Service]: Scheduling refresh of Service[ntp]
     Notice: /Stage[main]/Ntp::Service/Service[ntp]: Triggered 'refresh' from 1 events
     Notice: Finished catalog run in 5.36 seconds
```

Notice that our **"location-level"** hiera data has overridden the hiera data in **common.yaml**

What if we want to introduce a new location?  We simply create a new YAML file named to match the location name, and useing the .yaml extension.

Let's create a new location for Amsterdam like this:

```shell
     [root@puppet location]# pwd
     /etc/puppetlabs/puppet/environments/production/data/location
     [root@puppet location]# cp woodinville.yaml amsterdam.yaml
     [root@puppet location]# vi amsterdam.yaml
     [root@puppet location]# cat amsterdam.yaml
     ---

     ntp::servers:
       - '0.nl.pool.ntp.org'
       - '1.nl.pool.ntp.org'
       - '2.nl.pool.ntp.org'
       - '3.nl.pool.ntp.org'

```

Notice we've also changed the NTP servers to use one in the Netherlands.

We now have a new location setup in Hiera, so let's try changing our **agent** node to this new location, and then run puppet again...

```shell
     [root@agent ~]# vi /etc/puppetlabs/facter/facts.d/static-facts.yaml

     [root@agent ~]# cat  /etc/puppetlabs/facter/facts.d/static-facts.yaml
     ---
     location: amsterdam

     [root@agent ~]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1457383199'
     Notice: Location is: amsterdam
     Notice: /Stage[main]/Main/Notify[Location is: amsterdam]/message: defined 'message' as 'Location is: amsterdam'
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content:
     --- /etc/ntp.conf 2016-03-07 12:29:27.028387168 -0800
     +++ /tmp/puppet-file20160307-11029-1bedbos  2016-03-07 12:40:01.023326070 -0800
     @@ -23,10 +23,10 @@
      # prefer - select preferrable server
      # minpoll - set minimal update frequency
      # maxpoll - set maximal update frequency
     -server 0.us.pool.ntp.org
     -server 1.us.pool.ntp.org
     -server 2.us.pool.ntp.org
     -server 3.us.pool.ntp.org
     +server 0.nl.pool.ntp.org
     +server 1.nl.pool.ntp.org
     +server 2.nl.pool.ntp.org
     +server 3.nl.pool.ntp.org


      # Driftfile.

     Info: Computing checksum on file /etc/ntp.conf
     Info: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]: Filebucketed /etc/ntp.conf to main with sum 568159151d0a076ca61dc5e5c41b989f
     Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}568159151d0a076ca61dc5e5c41b989f' to '{md5}bd308381466e7050e0c9ca3e2f90c234'
     Info: Class[Ntp::Config]: Scheduling refresh of Class[Ntp::Service]
     Info: Class[Ntp::Service]: Scheduling refresh of Service[ntp]
     Notice: /Stage[main]/Ntp::Service/Service[ntp]: Triggered 'refresh' from 1 events
     Notice: Finished catalog run in 0.65 seconds
```

So what have we learned here?

1.  We can create agent-side custom facts.  We've created a static fact called **"location"**
2.  Facter facts automatically become puppet top-scope variables
3.  Any top-scope variable can be used in the hiera.yaml to define the hierarchy
4.  We observed that more-specific class parameters override less-specific ones

### Security Note ###

Did you notice that you affected the configuration of the host by simply changing the value of a agent-side fact?
You should be asking yourself the question:  do we want this ability and power on the agent side? Or do we prefer to "host" this power within our Hiera data?
Clearly, if we use agent-side facts, we want to ensure the facts are only writable by those we trust.

### Getting back to Hiera ###

Remember we were talking about how to use the **hiera()** lookup function?

In the above example, we were creating an agent-side yaml file to hold our
static facts.  What if we dont like the idea of the facts being stored
on the agent's filesystem?  We many not like that any user with root
could change those facts to something else, potentially bypassing change-control
proceedure, or even bypassing security?  Puppet does support something
called 'Trusted Facts' which stores a node's facts in its certificate, but
this is an advanced topic, and for the sake of illistrating how we can
use Hiera, we're going to take a different approach.

The approach here will be to define a hiera key called **location** and
we'll use it instead of the facter fact.

To do this, we will add the same key/value pair that we had previously
added to the node's facts.d/ directory to the hiera node-level yaml file
instead.

```shell
     [root@puppet node]# pwd
     /etc/puppetlabs/puppet/environments/production/data/node
     [root@puppet node]# tree
     .
     ├── agent.example.com.yaml
     └── puppet.example.com.yaml

     0 directories, 2 files
     [root@puppet node]# vi agent.example.com.yaml
     [root@puppet node]# vi puppet.example.com.yaml
     [root@puppet node]# cat agent.example.com.yaml
     ---

     location: amsterdam

     classes:
        - ntp
        - timezone

     timezone::timezone: 'US/Pacific'

     [root@puppet node]# cat puppet.example.com.yaml
     ---

     location: seattle

     classes:
        - ntp
        - timezone

     timezone::timezone: 'US/Pacific'
```

We've created a new key called **"location"** in each node-level yaml file.  We can now use the **hiera()** lookup function to query for that key and retrieve the value.
Let's edit our site.pp to accomplish that...

```

     #
     # Global - All code outside a node definition gets applied to all nodes
     #

     $location = hiera('location')

     notify{ "Location is: ${::location}": }

```

Now try running puppet on either node...

```shell
     [root@puppet node]# pwd
     /etc/puppetlabs/puppet/environments/production/data/node
     [root@puppet node]# cd ../../manifests/
     [root@puppet manifests]# vi site.pp
     [root@puppet manifests]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Error: Could not retrieve catalog from remote server: Error 400 on SERVER: Cannot reassign variable location at /etc/puppetlabs/puppet/environments/production/manifests/site.pp:43 on node puppet.example.com
     Warning: Not using cache on failed catalog
     Error: Could not retrieve catalog; skipping run
```

We got an error!  What happened?

Remember, any variable created in the site.pp automatically becomes a top-scope
variable.  Also, all facter facts become top-scope puppet variables.  In this
case, we have both a facter fact **location** as well as a puppet variable
assignment to **$location** happening in the site.pp, so we're getting an
error because **$::location** is already defined when we try to assign to it
a value.  Puppet only allows a variable to be set once, and only once. If you've
done any scripting or programming, you may be surprised that in puppet once you
assign a value to a variable, you can not re-assign to it again.  In fact,
it doesn't make much sense to call it a "variable" because it can not vary!

So, to get around this, we have to either remove the previously-created custom fact,
or rename one of the two.

Let's simply remove the fact that we had previously created, and prove that the
newly-created hiera key/value pair is taking over the responsibility of setting
the top-scope variable $::location

On both the **puppet** node and the **agent** node remove the custom-facts.yaml

```
     [root@puppet ~]# rm -f /etc/puppetlabs/facter/facts.d/static-facts.yaml
     [root@agent ~]# rm -f /etc/puppetlabs/facter/facts.d/static-facts.yaml
```

Now if we re-run puppet on both of our training nodes, we will see success!

But what's the advantage of doing this?  I can't run **facter location** anymore, and I liked that.

Now, the location variable is controlled within our Hiera data, and not on
the local agent node.  In theory, this is more secure, because your puppet
master should be more secure than any old agent node out there.

### Important note about using Hiera Data within the hiera.yaml ###

It's really important for you to notice that:

1.  We've defined the top-scope $::location variable in our site.pp
2.  We are using that top-scope variable in our hiera.yaml

How does this work?

Becuase we query hiera('location') in the site.pp, a new top-scope variable
is created, and this top-scope variable becomes availble to subsequent levels
within the hierarchy.  Crazy eh?

What this implies is that we should do any assignments like this in our site.pp
ONLY. This guarantees top-scope variables.  We should also use ONLY a single
manifest file at the top level, where the site.pp is sitting, even though
puppet supports having other manifests the same level.  This guarantees our
top-scope variables are set prior to any other code or modules needing to use
them.

For example, in the training exercises we've been working through, we've created
a common_hosts.pp and common_packages.pp at the top-level.  If we tried to use
the top-scope variable **$::location** inside either of those manifests, there is
no guarantee it has been defined yet.  The order in which puppet processes top-level
manifests is not defined, and the common_hosts.pp may be read prior to the site.pp,
and the $::location variable would be undefined at that point.

### Hiera vs Facter for static data ###

So, to summarize, we can use the hiera() lookup function and facter to do
the same thing, the difference being where the data is hosted--on the agent side,
or on the puppet master side.

Continue to **Lab #8** --> [Environments](/tutorial/08-Environments.md)

---

See also:

1. Hiera Lookup Functions: <https://docs.puppetlabs.com/hiera/1/puppet.html#hiera-lookup-functions>
2. Hiera Automatic-Parameter Lookup: <https://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup>
3. External Facts: <http://docs.puppetlabs.com/facter/2.4/custom_facts.html#external-facts>
4. What is Facter? <http://codingbee.net/tutorials/puppet/puppet-what-is-facter/>

---

Copyright © 2016 by Mark Bentley

