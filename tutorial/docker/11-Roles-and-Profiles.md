<-- [Back](10-Move-Puppet-Code-to-GitLab.md#lab-10)

---

# **Lab #11** - Roles and Profiles

---

### Overview ###

So where are we at now?

1.  We've moved our Puppet code and Hiera data into Git
2.  We've configured R10K to pull our Puppet code and Hiera data over to the Puppet Master
3.  We've also configured a Puppetfile within our control repo to pull in some external Puppet Modules

Where do we want to go?

1.  We want to learn more about using Git
2.  We want to learn more about Roles & Profiles
3.  We want to do some more Puppet coding to get practice
4.  We want to learn how to test our puppet code prior to pushing to production (develope a Workflow)
5.  We want to automate R10K so that it updates the master automatically after we push new code

We will see some Git usage as we move through this lab, and will cover the basics in the following lab.
Let's start by looking at the "Roles & Profiles Pattern"...

### Code Organization ###

We've already seen that there are multiple ways to classify a node:
1. node definition in the site.pp
2. using an ENC such as the PE Console
3. using Hiera to assign classes to a node

We have 3 different ways to choose from, and we can even mix and match if we wanted to.

We can create a big complex mess if we want to!

The same goes for writing Puppet code, and how to organize it.

We can...
1. Store individual manifests at the top level along with the site.pp (not recommended, especially in 3.8+)
2. We could create complete modules with site-specific code (has a learning curve)
3. We could create a sub-directory structure beneith the manifests directory, and sprinkle code there
4. We could create a couple special-purpose modules called **role** and **profile** to hold our code in a specific way

We're going to look at the 4th option:  Roles and Profiles

### Roles & Profiles ###

There's already been *a lot* written on the Roles & Profiles Pattern...
See:  [Further Reading](/share/YY-Further-Reading.md)

Roles and Profiles are just puppet manifests containing a class definition
and some code.  There's nothing special about them from Puppet's point of
view.  Puppet doesn't have any knowledge about something called a Role or
something called a Profile.  We, as the Puppet Code Maintainer, have simply
chosen to use those names, and it **us** that enforces their use.  To puppet, a
role class or a profile class is just another class.  You could just as easily
replace 'Role' with 'Foo' and 'Profile' with 'Bar', and you could acomplish
the same goal of keeping your code organized in a certain way.

The idea of a Role:
  - Each node is assigned exactly **one** role
  - That single role class would be assigned to the node using any node classification method
    - We will use Hiera to assign the role class to a node
  - The role class
    - simply contains a list of **include profile::<class>** statements
    - traditionally does **NOT** contain any conditional logic

The idea of a Profile:
  - contains code snipits that contain resource types to do real work
  - ideally the profile class would lookup any needed data in Hiera via auto-parameter lookup
  - one or more profiles would be bundled together to form a role
  - individual profile classes could be used across multiple roles if written to support that

For example, if you have an Application called 'FooDB' it might have a role called:

  - role::foo_db

And that role would be assigned to a particular node in order to make it a 'FooDB'.  The role::foo_db class might look like this:

```puppet
class role::foo_db {
  include profile::foo_db::apache
  include profile::foo_db::mysql
  include profile::foo_db::nfs_share
}
```

These other profile classes we are including are parts needed to make a
FooDB server, so when we assign **role::foo_db** to a node, it will get the
included profile classes for an Apache web server, a MySQL DB, and an NFS
share (probably mounts up a shared filesystem used by Apache and/or MySQL)

As you can see, we need to think a bit about how we organize our profile code,
as we want to reduce code duplication if possible, but at the same time we
want to maintain simplicity and readability of code.

That is key, so let's restate it:

*We want to maintain code simplicity and readability while reducing code duplication where possible*

### Where to put our Roles & Profiles? ###

Historically, PuppetLabs has been setting up customers with separate repositories
for each module, and because **role** and **profile** are technically modules,
they were placed in their own Git repositories.  So what you end up with is a
Puppetfile in your control repo that controls what modules are pulled in ot your
environment.  The *Puppetfile* would control both third-party modules (from the
Puppetlabs Forge, or from 3rd-party developers Git repositires) as well as your
own in-house-developed *site* modules.  You'd likely be pinning those modules
to a specific version or Git hash reference to guarantee production code is
static. (You wouldn't want some external module update to automatically trickle
in to your production environment until you've tested it.)

If you've done any work in a real production puppet environment you'll find
that maintaiing a Puppetfile within your control repo this way can cause some
angst, especially when using long-lived branches (like a staging and development
branch) in your workflow.

What happens is that each *Puppet Code Maintainer* has to have their own unique
Puppetfile in their feature branch of production to support testing their code in
a dynamic environemnt. This is an issue for a couple reasons:
1. have to branch off control repo, as well as every module involved in code change
2. have to edit their Puppetfile after branching off of the production branch
3. when merging in feature branch, need to take care *NOT* to merge in Puppetfile (which differs from prod)

If you're making changes/additions to your code on a daily basis, this can be a big pain.

Not only does the control repo need the feature branch, but so does any module repo youre working on.
This is so that when R10K builds the dynamic environment, they're able
to test all of their changed code and data. The Puppetfile would have the
modules, and each module that is being tested (e.g. role module, profile module)

The way PuppetLabs has said to get around
the issue is to simply *NOT* use long-lived branches in your workflow, and just
branch off of production with feature branches, then merge the feature branch in
to production after testing, and delete afterwards. 

This can work if you're using the merge as your gate into production (rather than
setting a hash ref on your in-house modules in the Puppetfile)

A better option (I believe) is to *NOT* do what has traditionally been done.  Let's
use our real-world experience as the justification to change the way we do things.

Let's just *Keep our in-house-developed site modules in the control repo.*  This way
every change to our own modules will be a change in the control repo, and our R10K
post-receive hook will be triggered too, so extra bonus.

Gary Larizzo, a PuppetLabs Pro Services Engineer, has recently written about this
on his blog here: [Gary Larizzo on Even Besterer Practices](http://garylarizza.com/blog/2015/11/16/workflows-evolved-even-besterer-practices/)

### Our Strategy ###

Our strategy to implement the Roles & Profiles Pattern:
1.  Create new **site/** directory within our control repo which will house role and profile modules/classes
2.  Create an **environment.conf** that inserts **site** at the head of the module search path
3.  Create a **base** profile, and move the common_hosts.pp and common_packages.pp classes out of **manifests/** dir

Why do we create a new **site/** directory? (By the way, you can call it whatever you like.)

Because we've configured R10K to pupulate the **modules/** directory on the
puppet master, if we create a **modules/** directory in our control repo,
anything in it will get pulled down to the master, but then when R10K pulls
down the modules as configured in the Puppetfile, it will blow away anything
in that directory, and plop the modules down in it.  To avoid that, we will
create another directory for modules called **site/** because these will be
our own site's modules (vs 3rd-party modules).   Another option for such a
directory might be **local/** for "my local code" but I'll let you lose
sleep over naming, and continue...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ mkdir -p site/role
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ mkdir site/profile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ cp manifests/common_*.pp site/profile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ find site
site
site/profile
site/profile/common_hosts.pp
site/profile/common_packages.pp
site/role
```

We've created our site directory containing a **role/** and **profile/** directory.
We've also copied our two common manifests into the profile directory in prep to swing over to  their use, rather than them being in the manifests directory along side the site.pp

Next, let's edit those two manifests in their new location to have the correct class names:

```puppet
class profile::common_hosts {
```

...and...

```puppet
class profile::common_packages {
```

The class name must match the underlying directory structure.

So, within your **site/profile/** directory, edit each of the manifest files to have the correct class name, then  add/commit/push, and then run r10k on the master...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)*$ git add *.pp
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  new file:   common_hosts.pp
  new file:   common_packages.pp

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)*$ git commit -m 'update class name'
[production 7af8714] update class name
 2 files changed, 45 insertions(+)
 create mode 100644 site/profile/common_hosts.pp
 create mode 100644 site/profile/common_packages.pp
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)$ git push
Counting objects: 8, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 730 bytes | 0 bytes/s, done.
Total 6 (delta 1), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   fb10cff..7af8714  production -> production
```

Now pop over to your master, and run r10k...

```
[root@puppet ~]# r10k deploy environment -vp
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/master
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/production
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/stdlib
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/ntp
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/timezone
```

But wait, how to we let puppet know to look in this new **site/** directory for puppet modules/classes?  We have to create an **environment.conf** and modify the modulepath to include this additional directory.

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)$ pwd
/Users/Mark/Git/Puppet-Training/control/site/profile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/site/profile] (production)$ cd ../..
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ echo 'modulepath = site:modules:$basemodulepath' > environment.conf
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git add environment.conf
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git commit -m 'create environment.conf to modify modulepath'
[production f639368] create environment.conf to modify modulepath
 1 file changed, 1 insertion(+)
 create mode 100644 environment.conf
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 5, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 341 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   7af8714..f639368  production -> production
```

Okay, now run r10k again on the master...

Now the real test is can we update our common.yaml in Hiera data to use the new **profile::common_hosts** and **profile::common_packages** ?  Let's try and see if it works...


```
---

classes:
   - profile::common_hosts
   - profile::common_packages

ntp::servers:
  - '0.pool.ntp.org'
  - '1.pool.ntp.org'
  - '2.pool.ntp.org'
  - '3.pool.ntp.org'
```

Commit/push that, and run r10k on the master...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ cd data
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)$ ls -al
total 8
drwxr-xr-x  6 Mark  staff  204 Mar  9 15:55 .
drwxr-xr-x  9 Mark  staff  306 Mar 11 11:06 ..
-rw-r--r--  1 Mark  staff  153 Mar  9 15:55 common.yaml
drwxr-xr-x  5 Mark  staff  170 Mar  9 15:55 location
drwxr-xr-x  5 Mark  staff  170 Mar  9 15:55 node
drwxr-xr-x  2 Mark  staff   68 Mar  9 15:41 role
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)$ cat common.yaml
---

classes:
   - common_hosts
   - common_packages

ntp::servers:
  - '0.pool.ntp.org'
  - '1.pool.ntp.org'
  - '2.pool.ntp.org'
  - '3.pool.ntp.org'

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)$ vi common.yaml
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

  modified:   common.yaml

no changes added to commit (use "git add" and/or "git commit -a")
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)*$ git commit -a -m 'point to new location for common_hosts and common_packages'
[production da520f3] point to new location for common_hosts and common_packages
 1 file changed, 2 insertions(+), 2 deletions(-)
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/data] (production)$ git push
Counting objects: 8, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 495 bytes | 0 bytes/s, done.
Total 4 (delta 1), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   f639368..da520f3  production -> production
```

Again, run r10k on the master after you push updates to the control repo...

```
[root@puppet ~]# r10k deploy environment -vp
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/master
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/production
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/stdlib
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/ntp
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/timezone
```

This will be the last itme I show the r10k output, as we're going to do this every time we update our control repo.  Eventually we'll automate this, but for now just get in the habit of running it by hand...

Oops.  I forgot, that since **profile** must conform to the puppet module format, we need to put our manifests within a manifests directory, so...

Okay, I've fixed that, re-pushed, and ran r10k, and now I get a good clean puppet run...

Next, let's remove the old common_hosts.pp and common_packages.pp, as we're no longer using them...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ ls -al
total 24
drwxr-xr-x   9 Mark  staff  306 Mar 11 11:06 .
drwxr-xr-x   3 Mark  staff  102 Mar  9 13:40 ..
drwxr-xr-x  15 Mark  staff  510 Mar 11 11:18 .git
-rw-r--r--   1 Mark  staff  241 Mar 10 13:10 Puppetfile
-rw-r--r--   1 Mark  staff   14 Mar  9 13:41 README.md
drwxr-xr-x   6 Mark  staff  204 Mar 11 11:09 data
-rw-r--r--   1 Mark  staff   42 Mar 11 11:06 environment.conf
drwxr-xr-x   5 Mark  staff  170 Mar  9 15:55 manifests
drwxr-xr-x   4 Mark  staff  136 Mar 11 10:52 site
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ cd manifests
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)$ ls -al
total 24
drwxr-xr-x  5 Mark  staff   170 Mar  9 15:55 .
drwxr-xr-x  9 Mark  staff   306 Mar 11 11:06 ..
-rw-r--r--  1 Mark  staff   567 Mar  9 15:55 common_hosts.pp
-rw-r--r--  1 Mark  staff   296 Mar  9 15:55 common_packages.pp
-rw-r--r--  1 Mark  staff  1655 Mar  9 15:55 site.pp
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)$ git rm common_hosts.pp
rm 'manifests/common_hosts.pp'
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)*$ git rm common_packages.pp
rm 'manifests/common_packages.pp'
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)*$ ls -al
total 8
drwxr-xr-x  3 Mark  staff   102 Mar 11 11:18 .
drwxr-xr-x  9 Mark  staff   306 Mar 11 11:06 ..
-rw-r--r--  1 Mark  staff  1655 Mar  9 15:55 site.pp
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  deleted:    common_hosts.pp
  deleted:    common_packages.pp

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)*$ git commit -a -m 'no longer used'
[production 708d37f] no longer used
 2 files changed, 45 deletions(-)
 delete mode 100644 manifests/common_hosts.pp
 delete mode 100644 manifests/common_packages.pp
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control/manifests] (production)$ git push
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 299 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   656f35f..708d37f  production -> production
```

Okay, great, so here's what our files/dirs look like now on the master:

```
[root@puppet production]# pwd
/etc/puppetlabs/puppet/environments/production

[root@puppet production]# tree data manifests site
data
├── common.yaml
├── location
│   ├── amsterdam.yaml
│   ├── seattle.yaml
│   └── woodinville.yaml
└── node
    ├── agent.example.com.yaml
    ├── gitlab.example.com.yaml
    └── puppet.example.com.yaml
manifests
└── site.pp
site
└── profile
    └── manifests
        ├── common_hosts.pp
        └── common_packages.pp

4 directories, 10 files
```

Note:  the **role/** directory hasn't shown up on the master yet, as git
wont commit it to the control repo until there's at least 1 file within.

Notice that we've just setup our repo to use the Roles & Profiles pattern,
but we've not used it yet.  Also notice that we've re-located a couple manifests
without our profile module, but we are assigning them in our common.yaml.
The take-away here should be that we can include profiles directly in our
classes hierarchy in Hiera, or we can assign a role, but a role would be
assigned at the node-level or role-level, not in the common.yaml.

Anyway, now that we're setup with the proper directory structure, and the
environment.conf to set the modulepath, let's do a real example to illistrate
how to use Roles and Profiles...

We also have to decide if we want to assign the role via a custom facter
fact? or do we want to use a hiera key/value pair?

---

Continue on to **Lab #12** --> [Git Basics](12-Git-Basics.md#lab-12)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

