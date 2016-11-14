<-- [Back](04-Install-Puppet-Agent.md#lab-4)

---

### **Lab #5** - Get Familiar with Puppet Config Files, Code, and CLI

---

### Overview

Time to complete:  60 minutes

In this lab, we will familiarize ourselves with:

- Puppet config file:  **puppet.conf**
- Puppet from the command line
- Puppet code basics
- Tieing code to a node (**Node Classification**)

In the previous labs we deployed a Puppet Master node and another with a
Puppet Agent.  Now what can we do with them?  Let's start by looking at
where puppet got installed, how we can use puppet to make a config change
on an agent system, and then we'll dig into puppet config and coding in
more depth...

### Where is Puppet Enterprise Installed?

Let's look at where PE installs itself, the config files
we should know about, and how to get started writing some
puppet code to do real work...

Let's start by looking at the **Puppet Master** (puppet.example.com)

The PE config file for Puppet, as well as the various
other components that come with PE (such as MCollective)
are stored under **/etc/puppetlabs**

As of PE 2015.x.y, the default location of puppet code is `/etc/puppetlabs/code`
(Historically, code has been in `/etc/puppetlabs/puppet/environments`, but this
is no longer the case.)

Let's look at Puppet and its config and code under:  **/etc/puppetlabs/code**

Here are the files and directories we will start looking at.

```
     [root@puppet ~]# tree /etc/puppetlabs/code

     /etc/puppetlabs/code
     ├── environments
     │   └── production
     │       ├── environment.conf
     │       ├── hieradata
     │       ├── manifests
     │       │   └── site.pp
     │       └── modules
     └── modules
```

The **site.pp** is the **main manifest** (also called the **site manifest**)
that puppet reads first.  It's the first bit of code that puppet parses, or
the point of entry into our Puppet codebase.  Every other bit of code "hangs off"
of the `site.pp`.  We will talk more about what things you can put in the `site.pp`
in the next lab.

Notice that there is a **production** directory, which corresponds to the
puppet **production environment**.  Out of the box, there is a single
environment called **production** although others can be created and used.

Within the `production/` directory, we have `manifests/`, `modules/`, and `hieradata/`.
There could also be directories for `files/` and `templates/` but they haven't been
created quite yet.

Some of these same directories are also used within each puppet module.  (A
module is just a bit of puppet code bundled up in a well-defined way, so that
it can be distributed, and used by other people easily.)  We'll learn more
about modules later, but for now just remember that the use of each directory
is well defined, and you shouldn't just use them for whatever you want:

* **files** - used for static files that your puppet code may reference
* **manifests** - where your `site.pp` lives, and potentially other site-developed code
* **modules** - any puppet modules you use go here, including site-developed modules
* **templates** - similar to the files dir, but holds marked-up files in ERB format

### The environments directory

Out-of-the-box, PE comes with a single environment setup, called the **production**
environment.   Environments are useful for containing different sets of modules,
code, and site data.  It's possible, for example, to
test a newer version of a module, or some puppet code you're actively developing,
in a different environment, totally seprate from the **production** environment.
This way, you can make changes to your code, test it on a test system, all without
ever having to worry about affecting production systems.  We will come back to
this topic in more depth in a subsequent lab...For now, just know this: Each
environment gets its own directory within the **environments** directory,
and each environment contains it's own set of manifests, modules, files,
templates, and Hiera data.

### The modules directory

The modules directory can contain additional Puppet code from PuppetLabs or
other third parties, or even in-house-developed  modules.  One common module
that is used by a lot of other Puppet modules is **stdlib**.  It is a sort of
"utility module" that adds on additional blades to your swiss army knife in
the form of resource types and functions.  It is also a PuppetLabs-supported
module.

Let's start to look at some of the things we might want to do from the
command line with respect to modules...

### List Installed Modules

Puppet Enterprise comes with some modules pre-installed.  To see what's installed,
run the `puppet module list` command as follows on your puppet node (The "Puppet Master"):

```
     puppet module list
```

And you should see something like this:

```
     [root@puppet puppetlabs]# puppet module list
     /etc/puppetlabs/code/environments/production/modules (no modules installed)
     /etc/puppetlabs/code/modules (no modules installed)
     /opt/puppetlabs/puppet/modules
     ├── puppetlabs-pe_accounts (v2.0.2-6-gd2f698c)
     ├── puppetlabs-pe_concat (v1.1.2-7-g77ec55b)
     ├── puppetlabs-pe_console_prune (v0.1.1-9-gfc256c0)
     ├── puppetlabs-pe_hocon (v2016.2.0)
     ├── puppetlabs-pe_infrastructure (v2016.4.0)
     ├── puppetlabs-pe_inifile (v2016.2.1-rc0)
     ├── puppetlabs-pe_java_ks (v1.2.4-37-g2d86015)
     ├── puppetlabs-pe_nginx (v2016.4.0)
     ├── puppetlabs-pe_postgresql (v2016.2.0)
     ├── puppetlabs-pe_puppet_authorization (v2016.2.0-rc1)
     ├── puppetlabs-pe_r10k (v2016.2.0)
     ├── puppetlabs-pe_razor (v1.0.0)
     ├── puppetlabs-pe_repo (v2016.4.0)
     ├── puppetlabs-pe_staging (v2015.3.0)
     └── puppetlabs-puppet_enterprise (v2016.4.0)
```

Notice that there are 3 different directories that puppet is looking for modules in:

* `/etc/puppetlabs/code/environments/production/modules`
* `/etc/puppetlabs/code/modules`
* `/opt/puppetlabs/puppet/modules`   <-- Modules used by PE itself are installed here

Since Puppet Enterprise uses itself to configure itself (e.g. Installing MCollective,
installing the PostgreSQL instance that sits behind PuppetDB, setup of the agent
installer repo, etc.), it makes sense that it would come with modules to help it do that.

If you're really curious, take a look at the installer log, and you'll see where
the puppet installer is using puppet to install and configure other components:

```
     more /var/log/puppetlabs/installer/installer.log
```

### Install a Puppet Module

What if you want to install a Puppet Module from the Puppet Forge?
(Follow along, and go ahead and run each command as we talk about them...)

```
     [root@puppet ~]# puppet module install puppetlabs/stdlib
     Notice: Preparing to install into /etc/puppetlabs/code/environments/production/modules ...
     Notice: Downloading from https://forgeapi.puppetlabs.com ...
     Notice: Installing -- do not interrupt ...
     /etc/puppetlabs/code/environments/production/modules
     └── puppetlabs-stdlib (v4.13.1)
```

Now look at your installed modules again, and you should see it in the list:

```
     [root@puppet ~]# puppet module list
     /etc/puppetlabs/code/environments/production/modules
     └── puppetlabs-stdlib (v4.13.1)
     [snip]
```

Notice that when you installed the Puppet Module, it was automatically
installed within the **production** environemnt.  By default modules
get installed in to the **first element of the modulepath**:

```
     [root@puppet ~]#  puppet config print modulepath
     /etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules
```

The modulepath contains colon-separated absolute paths to the locations where
puppet should search for puppet modules.  When making use of a module, the
Puppet Master will look in each directory from left to right until it finds
the module.  It will use the first module found if you have the same module
installed in multiple locations.

What if you want to use that same module in a different environment? And a
different version?

```
     [root@puppet environments]# cd /etc/puppetlabs/code/
     [root@puppet code]# mkdir -p environments/development/modules
     [root@puppet code]# puppet module install --environment development puppetlabs/stdlib --version 4.9.1
     Notice: Preparing to install into /etc/puppetlabs/code/environments/development/modules ...
     Notice: Downloading from https://forgeapi.puppetlabs.com ...
     Notice: Installing -- do not interrupt ...
     /etc/puppetlabs/code/environments/development/modules
     └── puppetlabs-stdlib (v4.9.1)
```

Notice now there are two environment directories (**development** and **production**), and
we've installed two different versions of the **stdlib** module.

```
     [root@puppet code]# tree -L 3 environments
     environments
     ├── development
     │   └── modules
     │       └── stdlib
     └── production
         ├── environment.conf
         ├── hieradata
         ├── manifests
         │   └── site.pp
         └── modules
             └── stdlib

     [root@puppet code]# grep '"version":' environments/*/modules/stdlib/metadata.json
     environments/development/modules/stdlib/metadata.json:  "version": "4.9.1",
     environments/production/modules/stdlib/metadata.json:  "version": "4.13.1",
```

* The development environment has v4.9.1
* The production environment has v4.13.0

What if we want to install a module in the "site modules" directory at /etc/puppetlabs/code/modules ?
Modules installed here would/could be used by any/every agent, regardless of environment.  It's like
a **common** or **global** modules repository.  Just remember that because puppet will search the
modulepath, if an environment's modules directory contains the same module, that will be used instead
of those found further down the module search path, such as in this case.

Let's try installing a different version of stdlib here...

```
     [root@puppet code]# puppet module install --target-dir /etc/puppetlabs/code/modules puppetlabs/stdlib --version 4.12.0
     Notice: Preparing to install into /etc/puppetlabs/code/modules ...
     Error: Could not install module 'puppetlabs-stdlib' (v4.12.0)
       Module 'puppetlabs-stdlib' (v4.13.1) is already installed
         Use `puppet module upgrade` to install a different version
         Use `puppet module install --force` to re-install only this module
```

Oops.  Puppet warns you that you're trying to install a module that is already installed and is newer.  Let's force the install...

```
     [root@puppet code]# puppet module install --target-dir /etc/puppetlabs/code/modules puppetlabs/stdlib --version 4.12.0 --force
     Notice: Preparing to install into /etc/puppetlabs/code/modules ...
     Notice: Downloading from https://forgeapi.puppetlabs.com ...
     Notice: Installing -- do not interrupt ...
     /etc/puppetlabs/code/modules
     └── puppetlabs-stdlib (v4.12.0)
```

Now, let's grep recursively through the files starting at our current-working-dir
and look for the string **"version"**.  This is a quick and easy way to see the
versions of all of the installed modules (every module should have a metadata.json
file with this string.)

```
     [root@puppet code]# grep -r '"version":' .
     ./environments/production/modules/stdlib/metadata.json:  "version": "4.13.1",
     ./environments/development/modules/stdlib/metadata.json:  "version": "4.9.1",
     ./modules/stdlib/metadata.json:  "version": "4.12.0",
```

You can also use the **puppet module list** command to see what modules are
installed for a particular environment, and their versions:

```
     puppet module list --environment=production
     puppet module list --environment=development
     puppet help module
```

We've just seen how to install a module manually.  Later on we will look at how
to use R10K to download and install puppet modules for us.

We will learn more about how to use different environments later.  For now let's
just use the default **production** environment.

before we move on to the next section, let's do a manual puppet run again on
both the puppet master and the agent node.

```
     puppet agent -t
```

Notice that after installing a module, that during the puppet run a whole bunch
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

### Puppet from the command line

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

### The Puppet Config File

Let's look at the **puppet.conf** a bit... Here's what a minimal agent-side
puppet.conf would look like:

```
     [main]
        server = puppet.example.com

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
     server = puppet.example.com
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
SSL cert.  It's the name that would show up when you run a `puppet cert list`
on the master as follows:

```
     puppet cert list --all
```

By default, the agent will run in the 'production' environment. In
Puppet Enterprise, the environment is communicated to the agent by
the PE Console, which functions as an ENC (External Node Classifier).

The environment can be overridden in the puppet.conf as well, though
additional steps are necessary to disable the PE Console ENC.  We will
cover this process in a later lab.  If the PE Console ENC is disabled,
we would then be able to specify the environment on the agent-side
in it's /etc/puppetlabs/puppet/puppet.conf as follows:

```
     [agent]
     environment = production
```

Again, the Puppet Enterprise Console controls what environment is assigned
to a node/agent "Out of the Box".  If you try to set the environment to
something other than what is set in the PE Console, the next puppet run
will cause the environemnt to be set back to what is configured by the
PE Console. For example, setting the environment to **development** as
follows would not work as intended (without some additional steps):

```
     [agent]
     environment = development
```

In fact, depending on the version of puppet you're running, this could
break your puppet agent, requiring you to manually edit the `puppet.conf`
to change the environment back to **production**.

In a later lab we will cover how we can change the environment
via the PE Console, as well as by editing the `puppet.conf`.

### Sections of the puppet.conf

The main, master, and agent sections control where a setting
is applicable.  The **[agent]** section applies to any puppet agent,
including the agent running on the master.  However, many of the settings
you typically find in the [agent] section on an agent, can also be
specified in the [main] or [master] section as well.  Anything you put
in the **[main]** section will apply to both the master and the agent.
Any settings you put in the **[master]** section will apply only to the
puppet master service, and any settings in the [agent] section will
apply just to the puppet agent itself.

If you change the puppet.conf, you should also **restart** the puppet
service so that it re-reads its config.


### Okay, so how do we run puppet manually?

The puppet agent will run automatically in the background
* Every 30 minutes if its cert has been signed, or...
* Every 5 minutes if it's waiting for its cert to be signed

However, you can also run the puppet agent manually.  You're going to
find out this is something you'll do a lot when you're developing
puppet code, and testing that it does what you want.  Simply run:

```
puppet agent -t
```

The **-t** or **--test** option tells the puppet agent to run in "test mode" which
enables several other options you'd want for testing your code: 'onetime',
'verbose', 'ignorecache', 'no-daemonize', 'show_diff', and some others.

Let's talk about what happens when you run **puppet agent -t**.  These
are the key things that happen, and in this order:

  1. Agent reads its puppet.conf (if running manually)
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

### Okay, Let's get our hands dirty...

---

### Let's make puppet manage the /etc/hosts file

One annoying thing about Vagrant is that if you configure the VM with a hostname,
Vagrant will automatically edit /etc/hosts to make sure the hostname entry is in
there, but it adds the hostname to the '127.0.0.1 localhost' line.  That's not
what we want.  And every time we stop and start the VM with Vagrant, it re-writes
the hosts file this way!

UPDATE:  this **was** the case for older versions of Vagrant, but newer versions
appear to fix this issue. (I'm using v1.8.4 on Mac OS X)  In any case, we will
continue with our example, because it's still a good example...

We want our /etc/hosts to have the following 4 lines, and only these 4 lines:

```
127.0.0.1      localhost
192.168.198.10 puppet.example.com puppet
192.168.198.11 agent.example.com  agent
192.168.198.12 gitlab.example.com gitlab
```

We know that puppet starts at the **site.pp** for every puppet run.  The site.pp
contains node definitions (that tells puppet what code to apply to what nodes),
as well as top-scope variables, and a little bit of puppet code to control
some of puppet's behavior.  The node definition controls what node, or set of
nodes, gets certain puppet code applied to it/them.  This idea of applying certain
bits of puppet code (or classes) to a node is called **Node Classification**.

Later on, we'll see how we can use Hiera to "classify" nodes as well, but for
now we will use good-old node definitions.

Login to the puppet master, become root, and cd in to:
/etc/puppetlabs/code/environments/production/manifests

```
     cd /etc/puppetlabs/code/environments/production/manifests
```

Edit the **site.pp** and add the following at the end of the file in the **node default** section:

```
     vi site.pp
```

Note:  if you don't know **vi** then you may **yum install** the editor of
your choice, and use that instead.

```
node default {

  # remove all unmanaged resources
  resources { 'host': purge => true }

  # add some host entries
  host { 'localhost':             ip => '127.0.0.1', }
  host { 'puppet.example.com':    ip => '192.168.198.10', host_aliases => [ 'puppet' ] }
  host { 'agent.example.com':     ip => '192.168.198.11', host_aliases => [ 'agent' ] }
  host { 'gitlab.example.com':    ip => '192.168.198.12', host_aliases => [ 'gitlab' ] }
}
```

Then do a **puppet agent -t** on both the master and agent.  Because we put this code
in the 'node default' definition, it will be applied to any node that isn't matched
by a more specific node definition (such as 'node agent { }' or 'node puppet { }').

```
     [root@puppet manifests]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for puppet.example.com
     Info: Applying configuration version '1477078262'
     Notice: Finished catalog run in 5.23 seconds
```

Nothing changed?

Remember that in a previous lab we setup our hosts file already.  Puppet looked at it
and saw that it was already correct (as per the config we put in the site.pp) so it
didn't make any changes.

Take a look at the /etc/hosts file on the **puppet** node, and notice it looks the same
as before:

```
127.0.0.1         localhost
192.168.198.10    puppet.example.com    puppet
192.168.198.11    agent.example.com     agent
192.168.198.12    gitlab.example.com    gitlab
```

The host entries may be in a different order, but the same 4 entries should be there, and hopefully none others.
The `purge => true` option we used in our code tells puppet to remove any un-managed host entries.  If you add
a new host entry outside of the puppet code, the next time puppet runs it will remove it.

Try this:  add the following to /etc/hosts manually using your favorite text editor:

```
1.2.3.4 unmanaged-host
```

Then run `puppet agent -t` and see what Puppet does...


```
[root@agent ~]# echo '1.2.3.4 unmanaged-host' >> /etc/hosts
```

Notice that we can resolve that name now:

```
[root@agent ~]# getent hosts unmanaged-host
1.2.3.4         unmanaged-host
```

Now run Puppet and watch what it does...

```
[root@agent ~]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for agent.example.com
Info: Applying configuration version '1477078872'
Notice: /Stage[main]/Main/Node[default]/Host[unmanaged-host]/ensure: removed
Info: Computing checksum on file /etc/hosts
Notice: Finished catalog run in 0.40 seconds
```

It removed the rogue entry we added! Nice!

```
[root@agent ~]# cat /etc/hosts
# HEADER: This file was autogenerated at 2016-10-21 19:41:12 +0000
# HEADER: by puppet.  While it can still be managed manually, it
# HEADER: is definitely not recommended.
127.0.0.1    localhost
192.168.198.10    puppet.example.com    puppet
192.168.198.11    agent.example.com    agent
192.168.198.12    gitlab.example.com    gitlab
```

So we've seen that Puppet recognized a change to /etc/hosts and un-did that change.

### The host resource

The `host { }` definition is called a **puppet resource type**, or just
the 'host resource' or simply a 'type'.  Depending on what documentation your're reading,
the author may call it a 'type' or a 'resource' or a 'resource type'.  It's all
the same thing.  To make things even more confusing (or interesting!), you can even define your
own custom resource types with the 'define' function.

For a complete list of all of the available built-in resource
types, see this page:

<http://docs.puppetlabs.com/puppet/latest/reference/type.html>

You may also use the **puppet describe** command to get info about any
resource from the command line.  For example, if you want to see the
parameters/attributes available to the host resource type, simply run:

```
     puppet describe host
```

Compare that with the **types reference** here:  <http://docs.puppetlabs.com/puppet/latest/reference/type.html#host>

If you want to see the current state of a particular resource type,
you can use the **puppet resource** command.  For example, if you want
to see all host resources on a system (not necessarily managed by
the puppet master), you could do:

```
     puppet resource host
```

...and you'd see something like this:

```
     host { 'gitlab.example.com':
       ensure       => 'present',
       host_aliases => ['gitlab'],
       ip           => '192.168.198.12',
       target       => '/etc/hosts',
     }
     host { 'agent.example.com':
       ensure       => 'present',
       host_aliases => ['agent'],
       ip           => '192.168.198.11',
       target       => '/etc/hosts',
     }
     host { 'localhost':
       ensure => 'present',
       ip     => '127.0.0.1',
       target => '/etc/hosts',
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
This is how Puppet **sees** the state of the system.  It's like looking
through Puppet's eyes, or how Puppet would see the system if it looked.

It's useful to show resources in this way when you are writing some puppet
code to enforce a config state, as you can easily cut-and-paste the code
for the resource into a manifest and modify it accordingly.

To further illistrate this, let's look at a service resource, and how the
output of 'puppet resource service puppet' changes as we stop/start or
enable/disable a service.

Let's see the current state of the puppet service on our puppetmaster:

```
     [root@puppet ~]# puppet resource service puppet
     service { 'puppet':
       ensure => 'running',
       enable => 'true',
     }
```

We see that the puppet service is both enabled, and running.

We can confirm that with the **systemctl** (on RHEL7) command as well:

```
     [root@puppet ~]#  systemctl status puppet
     ● puppet.service - Puppet agent
        Loaded: loaded (/usr/lib/systemd/system/puppet.service; enabled; vendor preset: disabled)
        Active: active (running) since Mon 2016-11-14 18:17:39 UTC; 5h 11min ago
      Main PID: 8308 (puppet)
        CGroup: /system.slice/puppet.service
                └─8308 /opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/bin/puppet agent --no-daemonize
```

Now, let's disable the service, but leave it running, and then show the output
of the puppet resource again.  Notice that the **enabled** attribute has changed to **false** now.

```
     [root@puppet ~]# systemctl disable puppet
     Removed symlink /etc/systemd/system/multi-user.target.wants/puppet.service.
```

Now check the puppet service resource:

```
     [root@puppet ~]# puppet resource service puppet
     service { 'puppet':
       ensure => 'running',
       enable => 'false',
     }
```

Let's stop the service, and then look again.  Notice that the **ensure** attribute has changed to **stopped** now.

```
     [root@puppet ~]# systemctl stop puppet
```

Now check the puppet service resource again:

```
     [root@puppet ~]# puppet resource service puppet
     service { 'puppet':
       ensure => 'stopped',
       enable => 'false',
     }
```

Now re-enable, and re-start the service, and look again...

```
     [root@puppet ~]# systemctl enable puppet
     Created symlink from /etc/systemd/system/multi-user.target.wants/puppet.service to /usr/lib/systemd/system/puppet.service.
     [root@puppet ~]# systemctl start puppet
```

Now let's check again...

```
     [root@puppet ~]# puppet resource service puppet
     service { 'puppet':
       ensure => 'running',
       enable => 'true',
     }
```

...and we are back to where we started.  Notice that the **puppet resource service puppet** command
simply shows the current state of that resoure at that moment in time.

---

### Okay, getting back to the host resource...

Remember that `puppet describe host` will show you all of the available
parameters for a host resource.

A host resource has a title, and several parameters/attributes.  The first item
in the host resource definition is the title (e.g. `puppet.example.com`) and the
subsequent name/value pairs are the parameters (e.g. `ip => 192.168.198.10`).
In this context, the term **attributes** may be better than **parameters**, as we
also use parameters when defining classes, and class parameters and type
attributes are two different things.

Note that the **host_aliases** attribute accepts an array (enclosed in square brackets `[ ]`),
while the **ensure** and **ip** attributes accept a string.

If you haven't already, take a look at the contents of the /etc/hosts file:

```
cat /etc/hosts
```

And we should see something like this...

```
     # HEADER: This file was autogenerated at 2016-01-19 18:25:19 +0000
     # HEADER: by puppet.  While it can still be managed manually, it
     # HEADER: is definitely not recommended.
     127.0.0.1       localhost
     192.168.198.10  puppet.example.com  puppet
     192.168.198.11  agent.example.com   agent
     192.168.198.12  gitlab.example.com  gitlab
```

At this point, every existing line in /etc/hosts is managed by puppet.
The host resource type manages each line individually, and we've added
each of the existing lines with puppet code.

Also, remember that we added the following bit of code to remove
any host entry that isn't managed by puppt:

```
  resources { 'host': purge => true }
```

...in other words, we now have a fully-managed /etc/hosts file.  If
someone comes along and adds a line to the /etc/hosts file without
realizing Puppet is managing it, the next time Puppet runs, they
will be in for a surprise!

The nice thing about managing every entry of /etc/hosts with puppet
is if our hosts file is deleted or corrupted in some way, Puppet will
re-write it entirely, and we dont have to worry about any entries
missing.  Let's try that on the **agent** node...

```
[root@agent ~]# rm -f /etc/hosts
```

Note:  We need at least one entry for the Puppet Master itself, otherwise the agent wont know what IP to talk to.
This is a great reason to be using DNS (so that our puppet master's IP would **always** be resolvable).

```
[root@puppet ~]# echo '192.168.198.10 puppet.example.com puppet' > /etc/hosts
[root@puppet ~]# puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for puppet.example.com
Info: Applying configuration version '1479166434'
Notice: /Stage[main]/Main/Node[default]/Host[localhost]/ensure: created
Info: Computing checksum on file /etc/hosts
Notice: /Stage[main]/Main/Node[default]/Host[agent.example.com]/ensure: created
Notice: /Stage[main]/Main/Node[default]/Host[gitlab.example.com]/ensure: created
Notice: Applied catalog in 13.83 seconds
```

See how Puppet added back all of the missing host entries?

```
[root@puppet ~]# cat /etc/hosts
# HEADER: This file was autogenerated at 2016-11-14 23:34:05 +0000
# HEADER: by puppet.  While it can still be managed manually, it
# HEADER: is definitely not recommended.
192.168.198.10  puppet.example.com  puppet
127.0.0.1       localhost
192.168.198.11  agent.example.com   agent
192.168.198.12  gitlab.example.com  gitlab
```

Go ahead and try adding some additional entries to /etc/hosts, and then run puppet again.  You should see puppet remove them:

I added this line:

```
1.2.3.4   foo.example.com foo
```

Then puppet ran an removed it:

```
     [root@agent /]# puppet agent -t
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1472432976'
     Notice: /Stage[main]/Main/Node[default]/Host[foo.example.com]/ensure: removed
     Info: Computing checksum on file /etc/hosts
     Notice: Finished catalog run in 0.55 seconds
```

If you dont see Puppet remove the entry, it could be that Puppet wasn't able to parse the hosts file, and
decided to silently do nothing.  I've observed that with PE 2016.4.0, if you have any whitespace before
your entry, Puppet will just ignore it, even though the system can still resolve it.  This is a bug if
you ask me, as Puppet is allowing an out-of-compliance file to exist without saying anything.  Is this
better or worse than what Puppet used to do?  In older versions of Puppet, if there was invalid content
in your /etc/hosts that Puppet couldn't parse, it would give up after having already started to re-write
the file with its header.  This left the /etc/hosts file truncated without any entries at all.  This
could obviously break the system, if critical entries exited in /etc/hosts that the application relies on.

Anyway...

---

Okay, that's enough for now.  Take a break, and let's move on to the next lab...

---

Let's re-visit what our goals were in this section:

* Puppet config file:  we looked at some of the important config
* Puppet from the command line: we used 'puppet help', 'puppet agent -t', etc.
* Puppet code basics: we got a little taste of puppet code
* Tieing code to a node via "classification": we used the default node definition in the `site.pp`

---

Continue to **Lab #6** --> [Practice doing some puppet code, and puppet runs](06-Puppet-Code-Practice.md#lab-6)

---

### Further Reading

For more info on how the site.pp **main manifest** is configured and used,
see the PuppetLabs docs at:

<https://docs.puppetlabs.com/puppet/latest/reference/dirs_manifest.html>

For more info on how the modulepath is used:

<https://docs.puppetlabs.com/puppet/latest/reference/dirs_modulepath.html#loading-content-from-modules>

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

