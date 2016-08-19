
---

### Lab #5 - Get Familiar with Puppet Config Files, Code, and CLI  ###

---

### Overview ###

Time to complete:  60 minutes

In this lab, we will familiarize ourselves with:

- Puppet config file:  **puppet.conf**
- Puppet from the command line
- Puppet code basics
- Tieing code to a node (**Node Classification**)

In the previous labs we deployed a Puppet Master and another VM with a
Puppet Agent.  Now what can we do with them?  Let's start by looking at
where puppet got installed, how we can use puppet to make a config change
on an agent system, and then we'll dig into puppet config and coding in
more depth...

---

### Where is Puppet Enterprise Installed? ###

Let's look at where PE installs itself, the config files
we should know about, and how to get started writing some
puppet code to do real work...

Let's start by looking at the **Puppet Master** (puppet.example.com)

The PE config file for Puppet, as well as the various
other components that come with PE (such as MCollective)
are stored under **/etc/puppetlabs**

Note:  this is different from "Open Source" Puppet, who's
config is installed under just /etc/puppet.  Because PE comes
with a many other components, each component has its own config
directory under /etc/puppetlabs. Puppet itself is just one
of those components, and utilizes /etc/puppetlabs/puppet to
store its config and code.  (Both the Puppet Master and Agent
uses this same directory.)

Let's look at Puppet and its config and code under:  **/etc/puppetlabs/puppet**

Here are the files and directories we will start looking at.

     /etc/puppetlabs/puppet
     ├── environments
     │   └── production
     │       ├── manifests
     │       │   └── site.pp
     │       └── modules
     ├── puppet.conf

The **site.pp** is the **main manifest** (also called the **site manifest**) that puppet reads first.
It's the first bit of code that puppet parses, and every other bit of code "hangs off" of the site.pp
We will talk more about what things you can put in the site.pp in the next lab.

Also, Out-of-the-Box you'll find some pre-created empty directories at the "top level" /etc/puppetlabs/puppet

     /etc/puppetlabs/puppet
     ├── files
     ├── manifests
     ├── modules

Some of these same directories are also used within each puppet module.  (A
module is just a bit of puppet code bundled up in a well-defined way, so that
it can be distributed, and used by other people easily.)  We'll learn more
about modules later, but for now just remember that the use of each directory
is well defined, and you shouldn't just use them for whatever you want:

* **files** - used for static files that your puppet code may reference
* **manifests** - where your site.pp lives, and potentially other site-developed code
* **modules** - any puppet modules you use go here, including site-developed modules
* **templates** - similar to the files dir, but holds marked-up files in ERB format

Each environment gets its own directory within the **environments** directory,
and each environment contains it's own set of manifests, modules, files
and templates.

### The modules directory ###

The modules directory can contain additional Puppet code from PuppetLabs or
other third parties, or even in-house-developed  modules.  One common module
that is used by a lot of other Puppet modules is **stdlib**.  It is a sort of
"utility module" that adds on additional blades to your swiss army knife in
the form of resource types and functions.  It is also a PuppetLabs-supported
module.

Let's start to look at some of the things we might want to do from the
command line with respect to modules...

What if you want to install a Puppet Module from the Puppet Forge?
(Follow along, and go ahead and run each command as we talk about them...)

```shell
# puppet module install puppetlabs/stdlib
Notice: Preparing to install into /etc/puppetlabs/puppet/environments/production/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/puppet/environments/production/modules
└── puppetlabs-stdlib (v4.11.0)
```

Notice that when you install a Puppet Module, it is automatically
installed within the production environemnt.  By default the module
gets installed in the first element of the modulepath:

```shell
# puppet config print modulepath
/etc/puppetlabs/puppet/environments/production/modules:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules
```

The modulepath contains colon-separated absolute paths to the locations where
puppet should search for puppet modules.  When making use of a module, the
Puppet Master will look in each directory from left to right until it finds
the module.  It will use the first module found if you have the same module
installed in multiple locations.

What if you want to use that same module in a different environment? And a
different version?

```shell
# cd /etc/puppetlabs/puppet
# mkdir -p environments/development/modules
# puppet module install --environment development puppetlabs/stdlib --version 4.9.1
Notice: Preparing to install into /etc/puppetlabs/puppet/environments/development/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/puppet/environments/development/modules
└── puppetlabs-stdlib (v4.9.1)
```

Notice now there are two environment directories (development and production), and
we've installed two different versions of the 'stdlib' module.

```shell
# yum install -y --quiet tree
# tree -L 3 environments
environments/
├── development
│   └── modules
│       └── stdlib
└── production
    ├── manifests
    │   └── site.pp
    └── modules
        └── stdlib

# grep '"version":' environments/*/modules/stdlib/metadata.json
development/modules/stdlib/metadata.json:  "version": "4.9.1",
production/modules/stdlib/metadata.json:  "version": "4.11.0",
```

* The development environment has v4.9.1
* The production environment has v4.11.0

What if we want to install a module in the "site modules" directory at /etc/puppetlabs/puppet/modules ?

```shell
[root@puppet puppet]# cd /etc/puppetlabs/puppet

[root@puppet puppet]# puppet module install --target-dir /etc/puppetlabs/puppet/modules puppetlabs/stdlib --version 4.10.0
Notice: Preparing to install into /etc/puppetlabs/puppet/modules ...
Error: Could not install module 'puppetlabs-stdlib' (v4.10.0)
  Module 'puppetlabs-stdlib' (v4.11.0) is already installed
    Use `puppet module upgrade` to install a different version
    Use `puppet module install --force` to re-install only this module

[root@puppet puppet]# puppet module install --target-dir /etc/puppetlabs/puppet/modules puppetlabs/stdlib --version 4.10.0 --force
Notice: Preparing to install into /etc/puppetlabs/puppet/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/puppet/modules
└── puppetlabs-stdlib (v4.10.0)

[root@puppet puppet]# grep -r '"version":' .
./modules/stdlib/metadata.json:  "version": "4.10.0",
./environments/production/modules/stdlib/metadata.json:  "version": "4.11.0",
./environments/development/modules/stdlib/metadata.json:  "version": "4.9.1",
```

You can also use the **puppet module list** command to see what modules are installed, and their versions:

```shell
puppet module list --environment=production
puppet module list --environment=development
puppet help module
```

We've just seen how to install a module manually.  Later on we will look at how
to use R10K to download and install puppet modules for us.

We will learn more about how to use different environments later.  For now let's
just use the default 'production' environment.

before we move on to the next section, let's do a manual puppet run again on
both the puppet master and the agent VM.

```shell
puppet agent -t
```

Notice that after installing a module, the during the puppet run a whole bunch
of Ruby files are downloaded and cached on the host.  Some of these are the
ruby code for custom facter facts, and others are ruby code for custom types
and providers that were implemented in the module.  Even before using the module,
these bits are downloaded and cached on the agent-side.

Also be aware that if the module is already in use, and you've just upgraded to
a newer version, the new module could behave differently than the old module, and
changes **could** be made.  This is why you should always test a new version of a
module in a different environment (other than production) prior to installing it
in production.  You could test on a test host to make sure any changes are correct,
before promoting the module to the production environment.  This practice of
testing code on a test host and in a test environment will be covered in a later
lab.






---

What other ways might we need/want to envoke puppet from the command line? ...

---

### Puppet from the command line ###

Explore the 'puppet' command on both the master and the agent.  Run the following commands
and take note of what they do.

```
     puppet help
     puppet help agent
     puppet agent -t
     puppet agent -t --noop
     puppet agent -t --debug
     puppet help config
     puppet config print
     puppet config print manifest
     puppet config print environment
     puppet config print modulepath
     puppet config print certname
```

---

### The Puppet Config File ###

Let's look at the **puppet.conf** a bit... Here's what a minimal agent-side
puppet.conf would look like:

```
[main]
   server = puppet

[agent]
   environment = production
   certname = agent.example.com
```

When you run puppet from the command line, how does it know what master
to talk to?  By default, puppet will look for a puppetmaster simply
called 'puppet'.  If the puppet.conf doesn't specify the server to talk to,
the agent will use the systems resolver to look for just 'puppet', and if
it's able to resolve that name, it will use the returned IP.

Note:  the puppet.conf conforms to the "INI File" format found historically
on MS-DOS/Windows systems.  It has sections.  Each **section** name
is enclosed in square brackets (e.g. **[main]**)  Each section can contain
any number of **name/value** pairs, which are the settings mapped within that
section.  Name/value pairs are seprated with an equal sign.

Rather than depend on the default behavior, we can explicitly set the
server name in the puppet.conf as follows:

```
[main]
server = puppet
```

Another important config item in the puppet.conf is the **certname**.
The certname typically corresponds to the FQDN of the host, but
you can choose to set it to whatever you like.

```
[agent]
certname = agent.example.com
```

The certname is what would be used when the agent contacts the master
for the first time, and submits a cert signing request for it's
SSL cert.  It's the name that would show up when you run a puppet
cert list on the master as follows:

```
puppet cert list --all
```

By default, the agent will specify an environment of 'production' as
well, but it's good practice to explicitly set the environment in the
puppet.conf so that it's clear what environment a host belongs to.
To specify the environment, not surprisingly, you'd have this in your
puppet.conf:

```
[agent]
environment = production
```

Note:  The Puppet Enterprise Console controls what environment is assigned
to a node/agent "Out of the Box".  If you try to set the environment to 
something other than what is set in the PE Console, the next puppet run
will cause the environemnt to be set back to what is configured by the 
PE Console.  In a later lab we will cover how we can change the environment
via the PE Console, as well as by editing the puppet.conf.  This will
include disabling the PE Console from doing node classification.

Note:  the main, master, and agent sections control where a setting
is applicable.  The **[agent]** section applies to any puppet agent,
including the agent running on the master.  However, many of the settings
you typically find in the [agent] section on an agent, can also be
specified in the [main] or [master] section as well.  Anything you put
in the **[main]** section will apply to both the master and the agent.
Any settings you put in the **[master]** section will apply only to the
puppet master service, and any settings in the [agent] section will
apply just to the puppet agent itself.

If you change the puppet.conf, you should also **restart** the pe-puppet
service so that it re-reads its config.


### Okay, so how do we run puppet manually? ###

The puppet agent will run automatically in the background
* Every 30 minutes if its cert has been signed, or...
* Every 5 minutes if it's waiting for its cert to be signed

However, you can also run the puppet agent manually.  You're going to 
find out this is something you'll do all of the time when you're developing
puppet code, and testing that it does what you want.  Simply run:

```
puppet agent -t
```

The **-t** or **--test** option tells the puppet agent to run in "test mode" which
enables several other options you'd want for testing your code: 'onetime',
'verbose', 'ignorecache', 'no-daemonize', 'show_diff', and some others.

Let's talk about what happens when you run **puppet agent -t**.  These
are the key things that happen, and in this order:

  1. Agent reads its puppet.conf
  2. Agent downloads and caches custom types and custom facts for the installed modules from the master
  3. Agent sends **facts** about itself to back to the puppet master (including the environment it is a part of)
  4. Puppet master uses variables (Facts and Puppet variables) along with puppet code to compile catalog for agent
  5. Master sends catalog back to agent to be applied
  6. Agent applies the catalog to the system

If you ever have to troubleshoot why a puppet run is failing, it will be
very useful to be able to identify at what point the run is failing.  I
have seen issues right up front when puppet is calling facter to collect
local systems facts, as well as when puppet is compiling the catalog on
the master, as well as when the catalog is being applied on the agent. In
each case, you'd focus on different things to fix the issue.   We'll talk
more about troubleshooting and tracing puppet runs later...

---

## The Lab ... ##

---

### Let's make puppet manage the /etc/hosts file ###

One annoying thing about Vagrant is that if you configure the VM with a hostname,
Vagrant will automatically edit /etc/hosts to make sure the hostname entry is in
there, but it adds the hostname to the '127.0.0.1 localhost' line.  That's not
what we want.  We want our /etc/hosts to have the following 4 lines:

```
127.0.0.1      localhost localhost.localdomain
192.168.198.10 puppet.example.com puppet
192.168.198.11 gitlab.example.com gitlab
192.168.198.12 agent.example.com  agent
```

The default /etc/hosts also has the IPv6 localhost entry, which we will
just remove.  It's not necessary for what we are doing here, and we will
be able to demonstrate some additional puppet technique.

We know that puppet starts at the **site.pp** for every puppet run.  The site.pp
contains node definitions (that tells puppet what code to apply to what nodes),
as well as top-scope variables, and a little bit of puppet code to control
some of puppet's behavior.  The node definition controls what node, or set of
nodes, gets certain puppet code applied to it.  This idea of applying certain
bits of puppet code (or classes) to a node is called **Node Classification**.

Later on, we'll see how we can use Hiera to "classify" nodes as well, but for
now we will use good-old node definitions.

Login to the puppet master, become root, and cd in to:
/etc/puppetlabs/puppet/environments/production/manifests

```
sudo su -
cd /etc/puppetlabs/puppet/environments/production/manifests
```

Edit the **site.pp** and add the following at the end of the file in the **node default** section:

```
node default {

  host { $::hostname:
    ensure => 'absent',
  } ->
  host { 'localhost4':
    ensure => 'absent',
  } ->
  host { 'localhost6':
    ensure => 'absent',
  } ->
  host { 'localhost':
    ensure => 'present',
    ip => '127.0.0.1',
    host_aliases => [ 'localhost.localdomain', ]
  }

  host { 'puppet.example.com': ip => '192.168.198.10', host_aliases => [ 'puppet' ] }
  host { 'gitlab.example.com': ip => '192.168.198.11', host_aliases => [ 'gitlab' ] }
  host { 'agent.example.com':  ip => '192.168.198.12', host_aliases => [ 'agent' ] }

}
```

Then do a **puppet agent -t** on both the master and agent.  Because we put this code
in the 'node default' definition, it will be applied to any node that isn't matched
by a more specific node definition (such as 'node agent { }' or 'node puppet { }').

The 'host { }' definition is called a 'puppet resource type', or just
the 'host resource' or even 'host type'.  Depending on what page your're reading,
the author may call it a 'type' or a 'resource' or a 'resource type'.  It's all
the same thing.  To make things even more confusing, you can even define your
own custom resource types with the 'define' function.

For a complete list of all of the available built-in resource
types, see this page:

<http://docs.puppetlabs.com/puppet/3.8/reference/type.html>

You may also use the **puppet describe** command to get info about any
resource from the command line.  For example, if you want to see the
parameters/attributes available to the host resource type, simply run:

```
puppet describe host
```

Compare that with the **types reference** here:  <http://docs.puppetlabs.com/puppet/3.8/reference/type.html#host>

If you want to see the current state of a particular resource type,
you can use the **puppet resource** command.  For example, if you want
to see all host resources on a system (not necessarily managed by 
the puppet master), you could do:

```
puppet resource host
```

...and you'd see something like this:

```
host { 'agent.example.com':
  ensure       => 'present',
  host_aliases => ['agent'],
  ip           => '192.168.198.12',
  target       => '/etc/hosts',
}
host { 'gitlab.example.com':
  ensure       => 'present',
  host_aliases => ['gitlab'],
  ip           => '192.168.198.11',
  target       => '/etc/hosts',
}
host { 'puppet.example.com':
  ensure       => 'present',
  host_aliases => ['puppet'],
  ip           => '192.168.198.10',
  target       => '/etc/hosts',
}
```

If you want to see the resource state for a particular user,  you
might run:

```
puppet resource user root
```

...and you'd see something like this:

```
user { 'root':
  ensure           => 'present',
  comment          => 'root',
  gid              => '0',
  home             => '/root',
  password         => '$1$v4K9E7xJ$gZIhJ5Jtqg5ZgZXeqSShd0',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '0',
}
```

Again, these resources arn't necessarily managed by the puppet master (but 
they could be).  We just don't know.  When you execute puppet in this way,
you're simply querying the state of the system at that moment in time.

It's useful to show resources in this way when you are writing some puppet
code to enforce a config state, as you can easily cut-and-paste the code
for the resource, and modify it accordingly.

To further illistrate this, let's look at a service resource, and how the
output of 'puppet resource service pe-puppet' changes as we stop/start or
enable/disable a service.

Let's see the current state of the pe-puppet service on our puppetmaster:

```shell
[root@puppet ~]# puppet resource service pe-puppet
service { 'pe-puppet':
  ensure => 'running',
  enable => 'true',
}
```

We see that the pe-puppet service is both enabled, and running.

We can confirm that with the systemctl command as well:

```shell
[root@puppet ~]# systemctl status pe-puppet
 pe-puppet.service - Puppet Enterprise Puppet agent
   Loaded: loaded (/usr/lib/systemd/system/pe-puppet.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2016-01-27 16:48:21 UTC; 37min ago
 Main PID: 3178 (puppet)
   CGroup: /system.slice/pe-puppet.service
           └─3178 /opt/puppet/bin/ruby /opt/puppet/bin/puppet agent --no-daemonize
```

Now, let's disable the service, but leave it running, and then show the output
of the puppet resource again.  Notice that the **enabled** attribute has changed to **false** now.

```shell
[root@puppet ~]# systemctl disable pe-puppet
Removed symlink /etc/systemd/system/multi-user.target.wants/pe-puppet.service.

[root@puppet ~]# puppet resource service pe-puppet
service { 'pe-puppet':
  ensure => 'running',
  enable => 'false',
}
```

Let's stop the service, and the look again.  Notice that the **ensure** attribute has changed to **stopped** now.

```
[root@puppet ~]# systemctl stop pe-puppet
[root@puppet ~]# puppet resource service pe-puppet
service { 'pe-puppet':
  ensure => 'stopped',
  enable => 'false',
}
```

Now re-enable, and re-start the service, and look again...

```
[root@puppet ~]# systemctl enable pe-puppet
Created symlink from /etc/systemd/system/multi-user.target.wants/pe-puppet.service to /usr/lib/systemd/system/pe-puppet.service.

[root@puppet ~]# systemctl start pe-puppet

[root@puppet ~]# puppet resource service pe-puppet
service { 'pe-puppet':
  ensure => 'running',
  enable => 'true',
}
```

...and we are back to where we started.  Notice that the **puppet resource service pe-puppet** command
simply shows the current state of that resoure at that moment in time.

---

### Okay, getting back to the host resource... ###

Remember that **puppet describe host** will show you all of the available
parameters for a host resource.

A host resource has a title, and several parameters/attributes.  The first item
in the host resource definition is the title (e.g. 'puppet.example.com') and the
subsequent name/value pairs are the parameters (e.g. 'ip => 192.168.198.10').
In this context, the term 'attributes' may be better than 'parameters', as we
also use parameters when defining classes, and class parameters and type
attributes are two different things.

Note that the 'host_aliases' attribute accepts an array (enclosed in square brackets [ ]),
while the 'ensure' and 'ip' attributes accept a string.

The code to deal with the localhost entry is a bit more complicated because what we
are saying is:

  1. first remove any host line containing the hostname (because vagrant adds the hostname to the localhost line.
  2. second remove any host line containing 'localhost4'
  3. and third, remove any host line containing 'localhost6' (at this point, both the localhost4 and localhost6 lines should be removed)
  4. add a simple localhost line containing only '127.0.0.1 localhost localhost.localdomain'

The arrow thingy **->** is what enforces the order that the resources are applied.
Without it, puppet could apply those host resources in any order, and we could
potentially get a different result every time. We want to ensure the resources with
the 'absent' are applied before the one with the 'present'.

Let's test halting our VM, and restarting it, running puppet again, and
make sure the hosts file looks like we want....

After doing a 'vagrant halt' and 'vagrant up' on both the puppet and agent VM's,
log back in, become root, and run 'puppet agent -t' again, then check /etc/hosts,
and what you should see is this:

```
cat /etc/hosts
```

And we should see something like this...

```
     # HEADER: This file was autogenerated at 2016-01-19 18:25:19 +0000
     # HEADER: by puppet.  While it can still be managed manually, it
     # HEADER: is definitely not recommended.
     192.168.198.10  puppet.example.com  puppet
     192.168.198.11  gitlab.example.com  gitlab
     192.168.198.12  agent.example.com agent
     127.0.0.1 localhost localhost.localdomain
```


At this point, every existing line in /etc/hosts is managed by puppet.
The host resource type manages each line individually, and we've added
each of the existing lines with puppet code.  In other words, we now
have a fully-managed /etc/hosts file.

Even so, Puppet's host resource isn't perfect...or maybe a better way
of stating it is it's not super-smart.  If you hand edit any of those
lines, and re-run puppet, it will likely add a new line to enforce the
puppet code.  Rather than hand-editing /etc/hosts, you should update
the puppet code to do what you want, otherwise you could end up with
both new and stale data across multiple-lines.  If the stale data
happens to come first in the hosts file, it will be used instead of the
new data.

For lines in /etc/hosts that are not managed by puppet, it is of
course safe to edit those. Puppet keys off of the first hostname
entry right after the IP, so that is the bit puppet uses to
recognize if a line exists in the correct state or not.

In theory, you could add additional host aliases, even for a line
that puppet manages, and be safe... Still feels un-safe to me though,
and I would not recommend that.  In fact, there is a way that we
can enforce managing the entire /etc/hosts file with puppet, and
puppet only. (So any lines added manually would be removed by
puppet.)   I'll cover this in a later lab.

Let's re-visit what our goals were in this section:

* Puppet config file:  we looked at some of the important config
* Puppet from the command line: we used 'puppet help', 'puppet agent -t', etc.
* Puppet code basics: we got a little taste of puppet code
* Tieing code to a node via "classification": we used the default node

---

Continue to **Lab #6** --> [Practice doing some puppet code, and puppet runs](/tutorial/06-Puppet-Code-Practice.md)

---

Further Reading:

For more info on how the site.pp **main manifest** is configured and used,
see the PuppetLabs docs at:

<https://docs.puppetlabs.com/puppet/3.8/reference/dirs_manifest.html>

For more info on how the modulepath is used:

<https://docs.puppetlabs.com/puppet/3.8/reference/dirs_modulepath.html#loading-content-from-modules>

---

