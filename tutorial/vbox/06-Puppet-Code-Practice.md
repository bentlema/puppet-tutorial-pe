<-- [Back](05-Puppet-Config-and-Code.md#lab-5)

---

### **Lab #6** - Some More Puppet Code Practice

---


### Overview

Time to complete:  60 minutes

The goal of this section is **NOT** to learn how to code.  We will write some
puppet code, but the **primary goal** of this lab is to learn:

 - More about tieing code to a node (**Node Classification**)
 - Where do you put your code on the master?
 - Why put code in a `class { }` ?
 - Defining code vs Declaring code
 - What is **the catalog** ?
 - How does puppet process your code files (manifests) and build the catalog?
 - Notice that we are editing code files directly on the master (Bad? Why?)
 - Notes on the `site.pp` and **top-scope variables** (will become important later)

### Node Classification

Remember from Lab #5, we talked about **classes** and **node classification**?

To review:

  - a class is simply a named block of puppet code that we can refer to by the class name.
  - we "tie" a class to a node through **node classification**, which simply says "apply this **class** to this **node**"

### The Catalog

We're going to start using the term **catalog** in the following sections, but what is the catalog?
Simply put, it's just the **compiled** version of your puppet code (manifests).  When the puppet
agent runs, it sends all of the facts about the system it's running on back to the puppet master.
All of the puppet code is sitting on the puppet master, and the master takes all of the built-in
puppet variables, facts, and code (conditional logic, functions, etc.) and compiles them into a
static set of instructions to be executed on the agent side.  All of these instructions are
executed on the agent side in a certain order as determined by the dependencies set forth in
your puppet code.  You'll learn more about ordering with dependencies later on, but for now,
just remember that the catalog is just all of your puppet code resolved down to the specific
instructions for the specific node it's being compiled for.

Another important concept to grasp is that when the catalog is compiled, all of the functions
and conditional logic you have in your manifests are evaluated on the master side, not the agent
side.  Puppet variables such as system facts are interpolated at this time as well.  All of the
decision-making within a manifest has already happened when the agent receives its catalog, so the
agent just executes the instructions it receives in the correct order.

Understanding what happens on the master side vs the agent side will become very important
later on, so just keep this in mind for now, and hopefully some questions will be triggerd
later on as we work through the tutorial.

### Defining Classes and Declaring Classes

First, we need to understand the difference between **defining** a class and **declaring** a class.

**Defining Classes**

- named blocks of Puppet code that are usually stored in modules for later use
- are NOT applied until they are invoked by name (declared)
- they can be added to a node’s catalog by either declaring them in your manifests
- or assigning them from an ENC (external node classifier.)

We've not yet talked about **Hiera**, an add-on to Puppet which is included in
Puppet Enterprise out-of-the-box.  Hiera, though not technically an ENC, can be
used like one.  We will learn more about Hiera in a later lab.  For now, we will
use node definitions along with the include or resource-style class declaration (with params)

Also, the PE Console comes configured OOTB as an ENC.  In a later lab
we will cover how this works, and we'll also disable this functionality in
order to enable Hiera to be used like an ENC.

**Declaring a class in a Puppet manifest**

- adds all of its resources to the catalog.

You can declare classes

- in node definitions at top scope in the site manifest (site.pp)
- in other classes (e.g. profile classes when using the Roles & Profiles paradigm)
- via an ENC (or use Hiera as an ENC)

The official PuppetLabs Docs talk at length about [Declaring Classes](https://docs.puppet.com/puppet/3.8/reference/lang_classes.html#declaring-classes)

Example of declaring a class at top-scope (in the site.pp) using the **include** statement:

```puppet
    include common_hosts
```

The class **common_hosts** would have to be defined in a file named `common_hosts.pp` and be found within the puppet codebase.
The **include** simply reads the manifest file, and declares (adds to the catalog) the resources in that class.

The nice thing about the **include** is that if the contained class has already been declared somewhere else, it wont be added to the catalog again (which would be a puppet error.)  Resources can only be declared **once** and only once.  If you try to declare the same resource (identified by its name) two or more times, puppet will throw an error.

If you put this include statement in your `site.pp`, outside of any
node definition, it would apply to every node.  (Note:  this is not the
same as putting it in the `node default { }` section, which only applies if
no other node definition matches.)

There is another way of declaring a class called **Resource-like Declarations** which we will ignore for now, as this style of declaration really wont be needed once we get to our section on **Hiera**.

You can read more about [Resource-like Declarations](https://docs.puppet.com/puppet/3.8/reference/lang_classes.html#using-resource-like-declarations) in the PuppetLabs documentation.

### More about Node Classification

Example of declaring a class for a specific node:

```puppet
    node foo_server {
      include foo_server_code
    }
```

This would look for a class called **foo_server_code** and declare it
ONLY for the node named **foo_server**.

Note:  Do not use the dash character in class names.  Underscore is allowed.

You can also specify multiple nodes in a single node definition, or even
use a regular expression to match multiple nodes.
You can read more about [Node Definitions](https://docs.puppetlabs.com/puppet/3.8/reference/lang_node_definitions.html)
in the official PuppetLabs docs.

...but guess what?  You probably wont care once you're introduced to **Hiera**, as
we'll be doing all of our node classification, and parameter passing via Hiera.

**Hiera Quick Preview**

Example of declaring a class via Hiera:

The `site.pp` would contain a call to Hiera like this:

```puppet
    hiera_include('classes')
```

Although node definitions could still be used, the power of Hiera is that you can
have puppet search a hierarchy of yaml files looking for a set of classes to be
applied on a per-node basis, as well as many other levels (or groupings).  For
example, you could specify a particular class be declared for all Linux systems,
or all Solaris systems, or all systems at a particular location, or that are a part
of a particular department.  The call to hiera_include('classes') will build up
a list of classes to apply for a node, but it can assemble this list of classes from
all levels throughout your hierarchy if you've declared classes at multiple levels.

With your Hiera config (`hiera.yaml`) already setup, you'd need to put somewhere within
your hierarchy a yaml file containing:

```yaml
    classes:
      - bar_server_code
      - some_other_class
```

This would cause the two classes to be declared for whatever level in the hierarchy
they have been declared.  For example, if you put this in a "node-level yaml" file,
they would get declared for the corresponding node.  If you put it in a yaml file
for a specific OS, they would get declared only for systems running that particular OS.

For now, we will ignore Hiera, but will come back to it in a later lab.  Hiera is
used almost universally these days, so it's not something to forget about.  Have
patience, and we'll get to it very soon!

### Let's write some code

Okay, let's shift gears now... We've talked a lot about how to declare classes, but
it may not make any sense until you start writing some code.

So let's start looking at some code to see if we can make these ideas make more sense...

Let's do a quick survey of what Puppet can do.

What if you want to install some packages?

```puppet

  package { 'bind-utils':
    ensure => 'installed'
  }

  package { 'dstat':
    ensure => 'installed'
  }

  package { 'git':
    ensure => 'installed'
  }

  package { 'tcpdump':
    ensure => 'installed'
  }

  package { 'net-tools':
    ensure => 'installed'
  }

```

This bit of code will install the latest version of these 5 packages, and
puppet will **NOT** track the versions installed.  If a newer version becomes
available in the host's software repos (e.g. configured yum repos), then
puppet wont notice, and will NOT do anything.  If you want puppet to install
the latest package, and track the version, and update when new version are
released, then you should use:

```puppet
    ensure => 'latest'
```

...in your package resource.

You can also specify a version of the package if you want to pin
the version to a very specific release, but this only works for systems
that have a 'versionalble' provider.  Yum allows this, but some older
package systems such as 'up2date' do not.

Let's add this code to a manifest file, and wrap it in a class definition.
A class allows us to refer to some code by name, and optionally pass in
parameters that the code within the class could access to further control
what the code does.

### Install Some Packages

Let's configure puppet to make sure certain packages are installed on our agent node.

Login to your puppet master node and become root

```
     cd /etc/puppetlabs/code/environments/production/manifests
     vi common_packages.pp
```

We will be adding this new manifest in the **production** environment in the **manifests** directory.

Notice that Puppet looks for code in the manifests directory based upon the environment it is a part of,
and the 'manifest' configuration value.

```
     [root@puppet]# puppet config print environment
     production

     [root@puppet]# puppet config print manifest
     /etc/puppetlabs/puppet/environments/production/manifests
```

In your common_packages.pp file add your code wrapped in a class with the same
name as the file, less the .pp extension, so like this:

```puppet
class common_packages {

  package { 'bind-utils':
    ensure => 'installed'
  }

  package { 'dstat':
    ensure => 'installed'
  }

  package { 'git':
    ensure => 'installed'
  }

  package { 'tcpdump':
    ensure => 'installed'
  }

  package { 'net-tools':
    ensure => 'installed'
  }

}
```

We've now **defined** a class, but this code will not do anything until we pin it to a node.
As soon as you save the manifest, puppet will *"see"* it on its next run.  It will know that
the class has been **defined**, but wont apply the code to any node until we **declare**
the class for a node.  Remember that thing called 'Node Classification'?

Let's classify the **agent node** with the **common_packages class**.

We will edit our `site.pp`

```
     vi site.pp
```

At the end of the `site.pp` add the following:

```puppet
node 'agent.example.com' {
   include common_packages
}
```

Save it, and then run 'puppet agent -t' on your agent VM, and you should see the packages get installed...

```
     [root@agent ~]# puppet agent -t
     Info: Using configured environment 'production'
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1479239887'
     Notice: /Stage[main]/Common_packages/Package[bind-utils]/ensure: created
     Notice: /Stage[main]/Common_packages/Package[dstat]/ensure: created
     Notice: /Stage[main]/Common_packages/Package[git]/ensure: created
     Notice: /Stage[main]/Common_packages/Package[tcpdump]/ensure: created
     Notice: Applied catalog in 19.05 seconds
```

Did you notice that only some of the packages were installed?  If you do a `yum info net-tools`
you'll notice that it was already installed, so puppet didn't do
anything for that package.  Note:  net-tools is required for puppet, so when we
installed puppet, that package was automatically installed.

Now that all 5 of these packages have been installed, if you run puppet again, no
additional changes will be made.  The host is as it should be.

### The default node

Now, I want to re-visit something we mentioned earlier.  Remember, the **node default**
only applies to a host **if no other** node definition matches it.  We've just added
a node definition for 'agent.example.com', so the default node definition will no longer apply.
The order of the node definitions doesn't matter.  To prove that this is the case,
go ahead and edit your `/etc/hosts` file on the agent.  DELETE the line with gitlab
on it, and then re-run 'puppet agent -t'.   Notice that puppet didn't re-add the line.

Let's take this opportunity to pull the code out of the 'node default' definition,
and put it in another manifest file called `common_hosts.pp`

Wrap that code in a class definition like this:

```puppet
class common_hosts {

  # remove all unmanaged resources
  resources { 'host': purge => true }

  # add some host entries
  host { 'localhost':             ip => '127.0.0.1', }
  host { 'puppet.example.com':    ip => '192.168.198.10', host_aliases => [ 'puppet' ] }
  host { 'agent.example.com':     ip => '192.168.198.11', host_aliases => [ 'agent' ] }
  host { 'gitlab.example.com':    ip => '192.168.198.12', host_aliases => [ 'gitlab' ] }

}
```

...save your new **common_hosts.pp** and let's, go back in to our site.pp and include it
for the agent node again.

Remove the host resources from the site.pp, and instead include the new class
contained in your new common_hosts.pp as follows:

```puppet
node default {
   include common_hosts
}

node 'agent.example.com' {
  include common_hosts
  include common_packages
}
```

Now re-run puppet agent -t on your agent node, and notice that the gitlab entry was added back.

```
     [root@agent ~]# puppet agent -t
     Info: Using configured environment 'production'
     Info: Retrieving pluginfacts
     Info: Retrieving plugin
     Info: Loading facts
     Info: Caching catalog for agent.example.com
     Info: Applying configuration version '1479240149'
     Notice: /Stage[main]/Common_hosts/Host[gitlab.example.com]/ensure: created
     Info: Computing checksum on file /etc/hosts
     Notice: Applied catalog in 0.69 seconds
```

The important point we're illustrating here is that the default node definition ONLY applies
if NO OTHER node definition matches.

Also, since we are including the common_hosts in both the default and the agent node
definitions, we could choose to move that include out of both so that it applies globally,
even if we add new hosts in the future with their own node definitions.

Let's edit our site.pp to look like this:

```puppet
node default {
}

node agent {
   include common_packages
}

include common_hosts
```


Notice now that the default node definition is empty, and only the agent
node definition includes the common_packages class.  Any and every host
will get the common_hosts class.  Let's run 'puppet agent -t' again
to prove that our code still works.

Again, remove the gitlab line in /etc/hosts on both agent and master, and
run puppet again, and you should see puppet add it back on both.

We are going to eventually want git on the master, so let's make one final
edit to our site.pp and move the common_packages include outside of the
node agent definition, leaving both 'node default' and 'node agent' definitions
empty.  Let's also add an empty node definition for the puppet master in case we want
to classify it uniquely later.  Finally, let's also re-order the code in to
a more intuitive order.  It makes no difference to puppet, but I think it's
more intuitive to humans this way:

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


Next time puppet runs on the puppet master, you'll notice that those packages get installed.

### Top-level Scope

Note:  node definitions can only be made at the top-level in the site.pp

**Top-Scope** is another way of saying **Globally-visible**.

Any variable declared in the `site.pp` is automatically a top-scope variable.
Top-scope variables are accessible throughout all of your puppet code by referencing them with '$::varname'

New in Puppet 3.8 (and later) is that any manifest at the top level is automatically read,
in additional to the `site.pp`, though I would recommend having ONLY a site.pp, and not
introducing other manifests at the top level as this can cause ordering issues if
you are reading in hiera data to set top-scope variables, and trying to use those
variables in other manifests at the top-scope.

### Affecting resource parameter defaults

Something else to simplify the code for our common_packages class:  Notice that we
have several packages, and we are doing the "ensure => 'installed'" for all of them.
To reduce the duplicated code, we could set a default attribute value for the Package
type like this:

```puppet
Package { ensure => 'installed' }
```

This default would apply to any/every other package resource we declare within
the manifest. We can still override the default on a per-resource basis if we
want to.  So our code could look like this:

```puppet
class common_packages {

  Package { ensure => 'installed' }

  package { 'bind-utils': }
  package { 'dstat': }
  package { 'git': }
  package { 'tcpdump': }
  package { 'net-tools': }

}
```

Notice that there is a definite difference when you use the lower-case version of
the resource type, vs using the upper-cased version.  Lower case declares the
resource, while uppercase refers to the resource type, but does NOT declare it.

When we say:

```puppet
   Package { ensure => 'installed' }
```

...what we are really saying is:  for every package resource declared, take these
attributes as defaults unless they are overridden by the individual resource declaration.

We could even put the Package ensure installed bit in the site.pp, and then it would
be a global default for package resources everywhere.  Pretty cool, huh?

We can override the default we just set by specifying the version string to the ensure parameter.
Example of pinning to a specific version/release of a package:

```puppet

  if ( $::operatingsystemmajrelease == '6' ) {
    package { 'nc': ensure => '1.84-24.el6' }
    package { 'nmap': ensure => '5.51-4.el6' }
  }

  if ( $::operatingsystemmajrelease == '7' ) {
    package { 'whois': ensure => '5.1.1-2.el7' }
  }

```

We also threw in a conditional statement there that checks the **OS Major Release** version **fact**.
If we are running an EL6 system, the **nc** and **nmap** packages will get installed to the specific version we've specified.
If we are running an EL7 system, the **whois** package will get installed to the specific version we've specified.
(This all assumes that the versions we've specified are available in our package repository.)

The slightly annoying thing here would be that if you were maintaining this package
across multiple platforms and versions, you'd have to manage the version/release
strings for each. For example, for the **whois** package, we might have several
different versions for each platform:

```
     5.1.0-1.el5
     5.1.1-3.el6
     5.1.1-2.el7
```

It's annoying that the platform (el5, el6, or el7) must be included in the
release for example.  If you don't include it, Puppet will not recognize the
version.  It would be preferable to be able to just say '5.1.1' and have the
provider figure out if we're running that version, but this wouldn't help us
if the '5.1.1' version isn't available on EL5, and we want to install '5.1.0'
there.

One solution to this problem could be using Hiera along with **$::operatingsystemmajrelease**
in the hierarchy, and then specifying the specific package version string for
each in the appropriate yaml file.  We will look at configuring Hiera in the
next lab, and show how to do this.

---

Continue to **Lab #7** --> [Config Hiera](07-Config-Hiera.md)

---

Further Reading:


[The Puppet Cookbook](http://www.puppetcookbook.com/) has many examples for
doing simple things, and is a nice place to visit to get code fragments to
accomplish many of the common things you'll want to do.

[The Puppet Language Reference about Classes](https://docs.puppetlabs.com/puppet/latest/reference/lang_classes.html)

[More about Catalog Compilation](https://docs.puppet.com/puppet/latest/reference/subsystem_catalog_compilation.html)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

