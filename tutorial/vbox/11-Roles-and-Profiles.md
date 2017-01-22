<-- [Back](10-Move-Puppet-Code-to-GitLab.md#lab-10)

---

### **Lab #11** - Roles and Profiles

---

### Overview

So where are we at now?

1.  We've moved our Puppet code and Hiera data into Git
2.  We've configured R10K to pull our Puppet code and Hiera data over to the Puppet Master
3.  We've configured a post-receive hook to trigger an R10K run automatically when we `git push`
3.  We've also configured a Puppetfile within our control repo to pull in some external Puppet Modules

Where do we want to go?

1.  We want to learn more about **using Git**
2.  We want to learn more about the **Roles & Profiles** pattern
3.  We want to do some more Puppet coding to get practice
4.  We want to learn how to **test our puppet code** prior to pushing to production (develop a Workflow)

We will see some Git usage as we move through this lab, and will cover the basics in the following lab.
Let's start by looking at the **"Roles & Profiles Pattern"**...

### Code Organization

We've already seen that there are multiple ways to classify a node:

1. node definition in the `site.pp`
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

### Roles & Profiles

There's already been *a lot* written on the Roles & Profiles Pattern...

See:  [Further Reading](../YY-Further-Reading.md)

Roles and Profiles are just puppet manifests containing a set of class definitions
and some code.  There's nothing special about them from Puppet's point of
view.  Puppet doesn't have any knowledge about something called a "Role" or
something called a "Profile".  We, as the **Puppet Code Maintainer**, have simply
chosen to use those names, and it is ***us*** that enforces their use in a specific
way..  To Puppet, a role class or a profile class is just another class.  You could
just as easily replace "Role" with "Foo" and "Profile" with "Bar", and you could
acomplish the same goal of keeping your code organized in a certain way.

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

For example, if you have an Application called 'FooApp' it might have a role called:

  - role::foo_app

And that role would be assigned to a particular node in order to make it a 'FooApp'.  The role::foo_app class might look like this:

```puppet
class role::foo_app {
  include profile::foo_app::users
  include profile::foo_app::nfs_share
  include profile::webserver::apache
  include profile::database::mysql
}
```

These other profile classes we are including are parts needed to make a
FooApp server, so when we assign **role::foo_app** to a node, it will get the
included profile classes for an Apache web server, a MySQL DB, and an NFS
share (probably mounts up a shared filesystem used by Apache and/or MySQL)

Notice that there are some application-specific classes (users, and nfs_share)
that are located within a `foo_app/` directory, while there are also some
general-purpose classes for an Apache web server and MySQL server, that many
other roles might share.  Hiera data would be used to configure these for
the specific application, so that the same profile code could be used by
multiple roles/applications.

As you can see, we need to think a bit about how we organize our profile code,
as we want to reduce code duplication if possible (maximize code reuse), but
at the same time we want to maintain simplicity and readability of code.

That is key, so let's restate it:

We want to maintain code **simplicity** and **readability** while
**reducing code duplication** and **maximizing code reuse** where possible.

### Where to put our Roles & Profiles?

We could treat our **role** and **profile** code directories like modules,
and put them in their own Git repos, and then use R10K to pull them in
just like it does for any other module.  The code within them would be
within the modulepath, so could be found no problem.

You'd end up with lines in your **Puppetfile** like this:

```
mod 'role',    :git => 'git@gitlab:puppet-role',    :ref => '857310c'
mod 'profile', :git => 'git@gitlab:puppet-profile', :ref => '026975a'
```
...or maybe specifying your feature branch instead of a hash ref:

```
mod 'role',    :git => 'git@gitlab:puppet-role',    :branch => 'my_feature'
mod 'profile', :git => 'git@gitlab:puppet-profile', :branch => 'my_feature'
```

We could point to a specific hash ref, tagged version, or even a specific branch
within our in-house **role** and **profile** modules.

Remember, the **Puppetfile** in your control repo controls what modules are pulled in
to your environment.  The **Puppetfile** would control both third-party modules
(from the Puppetlabs Forge, or from 3rd-party developer's Git repositires) as well
as your own **in-house-developed "site" modules**.  You'd likely be pinning those
modules to a specific version or Git hash reference to guarantee production code is
static. (You wouldn't want some external module update to automatically trickle
in to your production environment until you've tested it.)

With all of this said, there is a problem with doing this for your in-house
modules, especially if you're using **long-lived branches** in your workflow
(such as a **production**, **staging**, and **development** branch), and
especially if you make frequent changes.  You'd end up with differing
Puppetfile's in each branch pointing at the appropriate code.  The production
branch Puppetfile would point to the production branch of each module, while
the staging branch Puppetfile would point to the staging branch of each module,
etc.  The annoying part becomes evident the first time you want to merge from
development --> staging --> production and you realize the Puppetfiles are
different, and you want to keep them different.  Whether you use hash ref,
tagged version, or branch in your Puppetfile, you run into the same issue.

The way to get around the issue is to simply **NOT** use long-lived branches
in your workflow, and just branch off of production with feature branches,
then merge the feature branch in to production after testing, and delete afterwards.
In theory, you would have pulled the most recent version of the Puppetfile
when you created your feature branch, and hopefully you didn't take too long
to develop your feature.  When testing your code changes, you would have updated
the Puppetfile in your feature branch with the commit hash you're testing
against, and once you're ready to merge in to production, you could merge
everything, including the Puppetfile.

There's still the potential for a problem.  What if you took several days to
develop your new feature, and another person was also developing their own
feature, and they updated the Puppetfile in their feature branch?  You'll
eventually have to deal with getting the Puppetfile right.  It's just annoying,
isn't it?  Ultimately the problem comes down to a couple things:

1.  The Puppetfile lives in your control repo
2.  The **role** and **profile** modules are modified frequently by many users
3.  Every time the **role** or **profile** modules are updated, we need to update the Puppetfile

Every time the role and/or profile module is updated, the Puppetfile also has
to be updated, and R10K run to update the puppet environments.  It's likely if
you're working on a medium or large team, you have many people making changes
to the role and profiles modules on a daily basis (they are your glue code).
In order to test code in another puppet environment (your feature branch) the
Puppetfile would also have to be updated (in your feature branch), and then
when you go to merge your changes into production, you have to intentionally
omit your modified Puppetfile (if specifying branch names).  If specifying
a hash ref, you may be able to get away with merging in your Puppetfile, and
hope you dont conflict with another user (highly likely with a medium/large
team, and many people making changes/additions to the role and profile modules
at the same time.)

There is a simple solution to avoid all of this, and more and more folks
are doing it the following way...

### Keep it simple...

We really have no good reason to keep our **role** and **profile** modules
in their own Git repos, so let's take a different approach, and add another
path to the module search path.

We will just **keep our in-house-developed site modules in the control repo.**
(This would include the **role** and **profile** modules.) This way every change
to our own modules will be a change in the control repo, and our R10K
post-receive hook will be triggered too, so extra bonus.  And, the **BIG**
win here is that our in-house-developed modules would **NOT** need to be in
the Puppetfile.  R10K would still be used to pull over our control repo code, but
we wouldn't have to deal with the Puppetfile anymore (for in-house modules).

Our strategy to implement the Roles & Profiles Pattern:

1.  Create new `site/` directory within our control repo which will house
    role and profile modules
2.  Create an `environment.conf` that inserts **"site"** at the head of the
    module search path
3.  Create a **"base"** profile, and move the `common_hosts.pp` and `common_packages.pp`
    classes out of `manifests/` dir

Why do we create a new `site/` directory? (By the way, you can call it
whatever you like.)

Because we've configured R10K to populate the `modules/` directory on the
puppet master, if we create a `modules/` directory in our control repo,
anything in it will get pulled down to the master, but then when R10K pulls
down the modules as configured in the Puppetfile, it will blow away anything
in that directory, and plop the modules down in to it.  To avoid that, we will
create another directory for modules called **"site"** because these will be
our own site's modules (vs 3rd-party modules).   Another option for such a
directory might be **"local"** for "my local code" but I'm not going to lose
any sleep over naming and continue on...

So, change dir to your **puppet/control** repo, and...
(Note: the path to your control repo will be different than shown here.)

```
$ cd ~/puppet/control    # location of where you cloned your puppet control repo

(production)$ mkdir -p site/role/manifests

(production)$ mkdir -p site/profile/manifests

(production)$ cp manifests/common_*.pp site/profile/manifests

(production)*$ find site
site
site/profile
site/profile/manifests
site/profile/manifests/common_hosts.pp
site/profile/manifests/common_packages.pp
site/role
site/role/manifests
```

What have we done?

* We've created our `site/` directory containing a `role/` and `profile/` directory.
* We've created the `manifests/` directory within each as well (puppet looks for puppet code within a module here)
* We've copied our two common manifests into the profile module manifests directory (this will be there new home)

Next, let's edit those two manifests in their new location to have the correct
class names:

```puppet
class profile::common_hosts {
```

...and...

```puppet
class profile::common_packages {
```

**IMPORTANT**: The class name must match the underlying directory structure.

So, within your `site/profile/manifests/` directory, edit each of the manifest files
to have the correct class name, then  add/commit/push, and then run r10k on
the master...

```
(production)*$ cd site/profile/manifests/

(production)*$ vi common_hosts.pp

(production)*$ vi common_packages.pp

(production)*$ git add *.pp

(production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    new file:   common_hosts.pp
    new file:   common_packages.pp

(production)*$ git commit -m 'update class name'
[production d91192d] update class name
 2 files changed, 24 insertions(+)
 create mode 100644 site/profile/manifests/common_hosts.pp
 create mode 100644 site/profile/manifests/common_packages.pp

(production)$ git push
Counting objects: 7, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 838 bytes | 0 bytes/s, done.
Total 7 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   1b8679a..936baf3  production -> production

```

Notice that your post-receive hook ran, so it would have run R10K automatically for you.
You shouldn't have to run R10K manually on the puppet master any longer, but if for some
reason you didn't complete the post-receive hook config in the previous lab, you can
still run it manually on the master like always:

```
[root@puppet ~]# r10k deploy environment -vp
INFO     -> Deploying environment /etc/puppetlabs/puppet/environments/development
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/development/modules/motd
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/development/modules/ntp
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/development/modules/registry
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/development/modules/stdlib
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/development/modules/timezone
INFO     -> Deploying environment /etc/puppetlabs/puppet/environments/production
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/motd
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/ntp
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/registry
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/stdlib
INFO     -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/timezone
```

But wait, how do we let Puppet know to look in this new **"site"** directory for
puppet modules/classes?  We have to create an **environment.conf** and modify
the modulepath to include this additional directory.

So, back to your control repo...and let's add it...

Get back to the top level of your control repo:

```
(production)$ cd ../../..
```

Then create the new file `environment.conf` (if it doesn't already exist) and add a line to set the **modulepath**

```
(production)$ echo 'modulepath = site:modules:$basemodulepath' >> environment.conf

(production)*$ git add environment.conf

(production)*$ git commit -m 'create environment.conf to modify modulepath'
[production c0aeb1a] create environment.conf to modify modulepath
 1 file changed, 1 insertion(+)
 create mode 100644 environment.conf

(production)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 310 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   936baf3..9d64f56  production -> production

```

Now the real test is **can we update our common.yaml** in Hiera data to use the new **profile::common_hosts** and **profile::common_packages** ?  Let's try and see if it works...

Edit your `common.yaml` to look like this:
```
---

classes:
   - profile::common_hosts
   - profile::common_packages
   - motd

ntp::servers:
  - '0.pool.ntp.org'
  - '1.pool.ntp.org'
  - '2.pool.ntp.org'
  - '3.pool.ntp.org'
```

Commit/push that, and run r10k on the master...

```
(production)$ cd hieradata

(production)$ vi common.yaml

(production)*$ git commit -a -m 'point to new location for common_hosts and common_packages'
[production 9af5aa4] point to new location for common_hosts and common_packages
 1 file changed, 2 insertions(+), 2 deletions(-)

(production)$ git push
Counting objects: 4, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 474 bytes | 0 bytes/s, done.
Total 4 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   9d64f56..4a5909a  production -> production

```

Next, let's remove the old common_hosts.pp and common_packages.pp, as we're no longer using them...

```
(production)$ cd ../manifests/

(production)$ ls -al
total 24
drwxr-xr-x   5 bentlema  staff   170 Oct 25 12:11 .
drwxr-xr-x  10 bentlema  staff   340 Oct 28 06:48 ..
-rw-r--r--   1 bentlema  staff   447 Oct 25 12:11 common_hosts.pp
-rw-r--r--   1 bentlema  staff   189 Oct 25 12:11 common_packages.pp
-rw-r--r--   1 bentlema  staff  1687 Oct 25 12:11 site.pp

(production)$ rm -f common_hosts.pp

(production)*$ rm -f common_packages.pp

(production)*$ git commit -a -m 'no longer used in this location'
[production 02c52fe] no longer used in this location
 2 files changed, 24 deletions(-)
 delete mode 100644 manifests/common_hosts.pp
 delete mode 100644 manifests/common_packages.pp

(production)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 296 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   4a5909a..28151ab  production -> production

```

Okay, great, here's what our files/dirs look like now on the master:

```
[root@puppet environments]# cd /etc/puppetlabs/code/environments/production/
[root@puppet production]# tree hieradata manifests site
hieradata
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
but we've not really used it yet.  Also notice that we've re-located a couple manifests
within our profile module, but we are assigning them in our common.yaml.
The take-away here should be that we can include profiles directly in our
classes hierarchy in Hiera, or we can assign a role, but a role would be
assigned at the node-level or role-level, not in the common.yaml. (We build
a role class for a specific application.)

### TODO

Anyway, now that we're setup with the proper directory structure, and the
environment.conf to set the modulepath, let's do a real example to illistrate
how to use Roles and Profiles...

We should also mention how to use inheritance, as the one place it's still
considered okay to use is in the role class, where we inherit a more general
or common class, and then include application-specific classes to augment it.

### TODO

We also have to decide if we want to assign the role via a custom facter
fact? or do we want to use a hiera key/value pair?

---

Continue on to **Lab #12** --> [Git Basics](12-Git-Basics.md#lab-12)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

