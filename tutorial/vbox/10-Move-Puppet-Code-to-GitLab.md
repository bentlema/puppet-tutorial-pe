<-- [Back](09-Install-GitLab.md#lab-9)

---

# **Lab #10** - Move Puppet Code Under GitLab Control

---

## Overview

We've just setup GitLab in [Lab #9](09-Install-GitLab.md#lab-9) and now we
want to be able to use it.  We've already written some puppet code, and it's
currently sitting in `/etc/puppetlabs/puppet/environments` on our puppet
master node.  So we have a few questions:

- How can we get this code in to GitLab?
- Once it's in GitLab, how do we pull it back out into the correct place?
- Can we do this without any puppet outage?

We're going to walk through a process to copy our code to the **puppet/control**
repo that we've already cloned to our workstation, and then push it up to
GitLab.  Following that we will configure R10K to pull down our code from
GitLab, and drop it (along with all of the modules we're using) in the
correct place.  All of this will be done without seeing a failed puppet run
(say if one of the agents runs in the background while we're doing this work.)

## Some Git commands and concepts

What is a Push? Pull? What does it mean to **"clone a repo"**?  What is Git exactly?
We're going to talk more about Git commands in [Lab #12](12-Git-Basics.md), but we
need to know a few Git commands for this lab, so let's talk about them now.

What is Git?  Simply put, Git is a distributed version control system.
Git can be thought about like it's a mini-filesystem with snapshot capabilities,
and all of the Git commands you utilize manipulate this **"mini-filesystems"**
and its **"stream of snapshots"**.

Git is the tool that will...

- track changes to your code (audit trail)
- allow multiple code-maintainers to make changes simultaneously, and resolve conflicts
- allow multiple complete copies (or **"clones"**) of a repo which can be sync'ed up

Let's go over some of the basic Git concepts and commands we will see in this lab...

## Git Concept: The Git Repository

A **"Git Repo"** is just just a self-contained bundle of files along with its commit history.
As mentioned previously, this **commit history** is like a stream of snapshots.
Typically the files in a Git Repo are source code--in our case: Puppet Manifests.
However, a Git repo can contain any text and/or binary files.  Usually binary files
would be excluded from the repo, as you're probably not interested in versioning
them (e.g. they might be object files left from a compile/software build).  In any
case, Git is happy to store versions of any type of file you might want in your repo.

You can find many public Git repositories out on <https://github.com/explore> but
remember that the nice WebGUI is not the repo itself, it's just a **nice view** into the
repo.  GitHub is a Git server (or **"Git Hosting Service"**) sitting in front of the
actual Git repo--actually thousands of Git repos.  There are other Git servers out
there too, where both public and private repos can be hosted, and access-controled.
We are using one called GitLab for this training.

Some other well known Git servers available are:

- [GitHub](http://github.com)
- [Atlassian BitBucket](https://bitbucket.org/)
- [Gitolite](http://gitolite.com/)

## Git Command:  git clone

To make a complete copy of a remote repo, you can use `git clone <URL>`

- It makes an exact clone of the remote Git repository.
- Git will also setup a **remote** for pushing to and pulling from
- Git will also configure this remote as a **tracking branch**

The **remote** is just a meaningful name given to the remote URL which you can refer
to with other git commands.  Git will setup a remote with the name **origin** by default.

Type `git remote -v` to see the configured remote of your control repo.

Git will also use **origin** as the default for other commands if you don't
specify a remote.

## Git Command: git status

The `git status` command is useful for telling you what branch you're on, as
well as the status of the staging area.  When you make changes to files that
Git is tracking, it will notice that, and show you that it noticed.

## Git Concept: The Staging Area

Git has something called a **"Staging Area"** (sometimes referred to as
**"The Index"**).  It's where we can "stage" our changes in preperation
to permanently commit them to the repo.  Once you commit a change, it's
there forever in the commit history.

## Git Command: git add

To add a file to the staging area, use the `git add` command.  We can use
this command to add files to the staging area prior to commiting them.

## Git Command: git commit

Now that we're run the `git add` on a file, and the `git status` shows that
it's staged (ready to be committed), we can go ahead and either:

1. commit the change
2. un-stage the change

A typical commit would look like this:  `git commit -m 'some comment'`

The **-m** option is short for **commit message** and is just a descriptive message
to go along with the commit in case we need to find it in the future, the message
should make it easier to identify later what changes were made

## Git Command: git push

Remember earlier we looked at `git clone` and mentioned that when we clone a
repo, Git will automatically setup the remote tracking branch.  Git is comparing
our repo's branch with what it knows about the remote repo's branch, and it will
notice when we have made a new commit, but the remote doesn't yet have that commit.

We need to `git push` to send our local commits to the remote repository.

## Git Command: git pull

If you have multiple people working in the same repo, they will also have a
clone on their local workstation, and will also be making changes and
adding/committing/pushing up to the remote.  If you're both working on the
same files, it's possible you could have an outdated copy if the other person
had edited a file and pushed their change to the remote after you cloned it.
So how to we keep our **local** clone up-to-date with the **remote**?

A good habit to get into is to also do a `git pull` prior to doing any work
in your local clone of a repo.  This ensures you're pulling down any changes
other folks have made, and will potentially avoid merge conflicts in the future.

When you do a `git pull` Git will pull down changes to the current branch,
and bring your branch up-to-date with the remote.  Git can also be configured
to fetch all changes in other branches as well.  Depending on the version of
Git your using, this behavior may differ, so just to be safe, it's also good
to `git pull` after switching to a different branch.

## Git Concept: Git Branches

Although we've seen **branches** a little bit (e.g. **production branch**) we've
not really talked about what a branch is.  Git allows us to spin off a copy of
our repo, makes changes within that copy (called a branch), and then either
merge our changes up to the parent branch, or discard our changes.  This idea
becomes very useful when making changes to puppet code without affecting the
production environment, but still allowing us to test our code.

## Git Command: git checkout

The easiest way to create a new branch is to use `git checkout -b <branch-name>`

It's a shortcut for creating a branch, and then checking out that branch.

The longer version would be a `git branch <branch-name>`
followed by `git checkout <branch-name>` but why type all of that?

## Okay, shifting gears...

With these Git concepts and commands in mind, let's work on getting our existing
Puppet code into GitLab (our Git hosting server).

GitLab provides the authentication/authorization framework around our puppet/control repo.
We've previously setup our own account, and cloned the puppet/control repo to our
workstation, but we will also need to allow the root user on our puppet master access
to clone the control repo as well, as this repo is where we will store some of our
puppet code and hiera data.

## Let's Setup root SSH access to GitLab

So, to recap...

- Puppet runs as root
- Puppet runs the `r10k` command to build puppet environments from Git branches
- R10K uses the git command to clone and pull repos down to the puppet master
- The git command will use ssh keys to authenticate with the GitLab server

Knowing this, let's setup the **root** user on the puppet master to be able to
**clone** the **puppet/control repo** which we setup in the previous lab. If we're
able to manually clone the repo as the root user, than so should R10K be able to.

First, as root on your **puppet** VM, generate a new passphraseless keypair as follows:

```
[root@puppet ~]# ssh-keygen -t rsa -b 2048 -N '' -C 'root@puppet - Used by R10K to pull from GitLab'
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
e1:e3:ce:c4:a3:e7:f8:17:dc:f8:7e:fa:f2:c1:3d:c3 root@puppet - Used by R10K to pull from GitLab
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
|                 |
|        .        |
|       . .       |
|        S. o     |
|       o .+ .... |
|        =  o  oE.|
|       *... o ..o|
|      o+=. .o*o  |
+-----------------+
```

r10k will need to be able to pull from GitLab without having to enter a password, so leave the **passphrase** empty.
(That's what the `-N ''` option does, so you shouldn't even be prompted to provide a passphrase.)

Next, within the GitLab WebGUI

- Go to your **puppet/control** project (repo)
- Find and click the **'Settings Gear Icon'** (location differs depending on verson of GitLab)
- Click on **'Deploy Keys'**
- Click **'New Deploy Key'**
- Put a meaningful title like **'Used by R10K to pull from GitLab'**
- Copy and paste in the **public key** you just generated
- Save it by clicking **'Create New Deploy Key'**

At this point, the root user on the **puppet* VM should be able to clone the repo.

## Test that the root user can clone the puppet/control repo

```
[root@puppet .ssh]# cd /tmp
[root@puppet tmp]# git clone ssh://git@gitlab/puppet/control.git
Cloning into 'control'...
The authenticity of host 'gitlab (192.168.198.11)' can't be established.
ECDSA key fingerprint is 39:e5:9b:0d:8b:bd:74:0a:12:e8:c6:37:cb:cf:17:c3.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'gitlab,192.168.198.11' (ECDSA) to the list of known hosts.
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3/3), done.
```

Works!

## Create new branch called 'production'

In the GitLab webGUI, create a new branch called 'production'

## Test that R10K can pull down your code

R10K knows to look for its config file in `/etc/puppetlabs/r10k/`

Create an `/etc/puppetlabs/r10k/r10k.yaml` containing the following:

```yaml
---
cachedir: '/var/cache/r10k'

sources:
  puppet-training:
    remote:  'git@gitlab:puppet/control'
    basedir: '/tmp/r10k-test'
```

**WARNING**: Make sure that before you save this file that the **basedir**
is set to a temporary location, and not the default.  If you leave the **default**
as in the example `r10k.yaml.example`, you will blow away all of your existing
code.  Very very bad bad!  We don't want to do that yet.

```
[root@puppet ~]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO   -> Deploying environment /tmp/r10k-test/master
INFO   -> Deploying environment /tmp/r10k-test/production
```

Cool.  So we successfully tested that r10k runs using our test `r10k.yaml` file will work

```
[root@puppet tmp]# tree r10k-test
r10k-test
├── master
│   └── README.md
└── production
    └── README.md

```

Notice that R10K created an environment for each branch found in the Git repo.  We see
the original **master** branch (the initial branch that a new Git repo always comes with)
and the **production** branch, which we created in the GitLab WebGUI.  Both get their
own environment directory.

## Let's Move Our Existing Puppet Code In To GitLab

How do we get our existing puppet code in to GitLab?

We've given the root user the ability to clone/pull code, but it can not
push code (we're using a Deploy Key, which gives read-only access)

Should we temporarily give root access to push to the repo?  That's one option,
but since we've already cloned the repo to our workstation, and tested pushing
back and know it works, let's simply copy the files we need from the puppet
master to our local clone of the repo.

Let's take advantage of the `/share` mount, which is shared between our VM and our host.
If we copy the needed files there (from within the VM) we will be able to copy them
into place from the host side, and then commit to our Git repository, and push up to GitLab.

1. On your **puppet** VM,  identify the files we need (within `/etc/puppetlabs/puppet/environments`)
2. Copy those files over to `/share` (still within the VM)
3. Then in another terminal window, on the host side, copy from your `puppet-training-pe/share` directory...
4. ...to the location of your clone of the **puppet/control** repo

So, in my case, this 2-stage copy will look like this:

**Stage 1**:  On my puppet master VM, Copy each environment directory...
```
   From: /etc/puppetlabs/puppet/environments
   To:   /share
```
**Stage 2**: On my host workstation, Copy each environment directory...
```
   From: /Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share
   To:   /Users/mbentle8/Documents/Git/Puppet-Training/control
```

Note that when we get the the **Stage 2** copy, we eliminate the actual
environment directory name, and instead ensure that the proper **Git Branch**
is checked out when we copy.  We will be copying the **production/** directory
over to the **production branch** within our Git repo, and likewise for the
**development/** directory and branch.

So within the **puppet** VM I'm going to start by copying the **production**
environment over to `/share`

```
[root@puppet environments]# cd /etc/puppetlabs/puppet/environments
[root@puppet environments]# ls -al
total 4
drwxr-xr-x 4 pe-puppet pe-puppet   41 Oct 21 11:52 .
drwxr-xr-x 7 root      root      4096 Oct 21 14:50 ..
drwxr-xr-x 5 root      root        47 Oct 24 13:06 development
drwxr-xr-x 5 root      root        47 Oct 21 14:49 production
[root@puppet environments]# cp -r production /share
```

Now on the host side (outside of the VM) copy those files using **rsync** to your repo like this:

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ pwd
/Users/mbentle8/Documents/Git/Puppet-Training/control

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ ls -al
total 8
drwxr-xr-x   4 mbentle8  staff  136 Oct 24 15:07 .
drwxr-xr-x   8 mbentle8  staff  272 Oct 24 15:06 ..
drwxr-xr-x  13 mbentle8  staff  442 Oct 24 15:33 .git
-rw-r--r--   1 mbentle8  staff   15 Oct 24 15:07 README.md

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ ls -al /Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share
total 8
drwxr-xr-x   5 mbentle8  staff  170 Oct 24 15:33 .
drwxr-xr-x  15 mbentle8  staff  510 Oct 20 15:25 ..
-rw-r--r--   1 mbentle8  staff  137 Oct 19 14:02 README.md
drwxr-xr-x   5 mbentle8  staff  170 Oct 24 15:33 production
drwxr-xr-x   7 mbentle8  staff  238 Oct 19 14:02 software

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ git checkout production
error: pathspec 'production' did not match any file(s) known to git.

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ git pull
From ssh://localhost/puppet/control
 * [new branch]      production -> origin/production
Already up-to-date.

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (master)$ git checkout production
Branch production set up to track remote branch production from origin.
Switched to a new branch 'production'

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ ls -al
total 8
drwxr-xr-x   4 mbentle8  staff  136 Oct 24 15:07 .
drwxr-xr-x   8 mbentle8  staff  272 Oct 24 15:06 ..
drwxr-xr-x  15 mbentle8  staff  510 Oct 24 15:34 .git
-rw-r--r--   1 mbentle8  staff   15 Oct 24 15:07 README.md

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ rsync -acv /Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share/production/* .
building file list ... done
data/
data/common.yaml
data/location/
data/location/amsterdam.yaml
data/location/seattle.yaml
data/location/woodinville.yaml
data/node/
data/node/agent.example.com.yaml
data/node/gitlab.example.com.yaml
data/node/puppet.example.com.yaml
data/role/
manifests/
manifests/common_hosts.pp
manifests/common_packages.pp
manifests/site.pp
modules/
modules/motd/
modules/motd/CHANGELOG.md
modules/motd/Gemfile
modules/motd/LICENSE
modules/motd/README.md
modules/motd/Rakefile
modules/motd/checksums.json
modules/motd/metadata.json
modules/motd/manifests/
modules/motd/manifests/init.pp
[snip]
modules/ntp/
modules/ntp/CHANGELOG.md
modules/ntp/CONTRIBUTING.md
modules/ntp/Gemfile
modules/ntp/LICENSE
modules/ntp/NOTICE
modules/ntp/README.markdown
modules/ntp/Rakefile
modules/ntp/checksums.json
modules/ntp/metadata.json
modules/ntp/lib/
modules/ntp/lib/puppet/
modules/ntp/lib/puppet/parser/
modules/ntp/lib/puppet/parser/functions/
modules/ntp/lib/puppet/parser/functions/ntp_dirname.rb
modules/ntp/manifests/
modules/ntp/manifests/config.pp
modules/ntp/manifests/init.pp
modules/ntp/manifests/install.pp
modules/ntp/manifests/params.pp
modules/ntp/manifests/service.pp
[snip]
sent 1180548 bytes  received 14620 bytes  796778.67 bytes/sec
total size is 1125236  speedup is 0.94

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ ls -al
total 8
drwxr-xr-x   7 mbentle8  staff  238 Oct 24 15:35 .
drwxr-xr-x   8 mbentle8  staff  272 Oct 24 15:06 ..
drwxr-xr-x  15 mbentle8  staff  510 Oct 24 15:35 .git
-rw-r--r--   1 mbentle8  staff   15 Oct 24 15:07 README.md
drwxr-xr-x   6 mbentle8  staff  204 Oct 24 15:33 data
drwxr-xr-x   5 mbentle8  staff  170 Oct 24 15:33 manifests
drwxr-xr-x   7 mbentle8  staff  238 Oct 24 15:33 modules

```

Okay, we just copied over the entire production environment (Hiera data, manifests and modules) to our clone of the control repo.

Next we need to commit it to our Git repo...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git add data
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git add manifests
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git add modules

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git commit -m 'initial add of production env'
[production 5af0cc7] initial add of production env
 635 files changed, 31786 insertions(+)
 create mode 100644 data/common.yaml
 create mode 100644 data/location/amsterdam.yaml
 create mode 100644 data/location/seattle.yaml
 create mode 100644 data/location/woodinville.yaml
 create mode 100644 data/node/agent.example.com.yaml
 create mode 100644 data/node/gitlab.example.com.yaml
 create mode 100644 data/node/puppet.example.com.yaml
 create mode 100644 manifests/common_hosts.pp
 create mode 100644 manifests/common_packages.pp
 create mode 100644 manifests/site.pp
 create mode 100644 modules/motd/CHANGELOG.md
 create mode 100644 modules/motd/Gemfile
 create mode 100644 modules/motd/LICENSE
 create mode 100644 modules/motd/README.md
 create mode 100644 modules/motd/Rakefile
 create mode 100644 modules/motd/checksums.json
 create mode 100644 modules/motd/manifests/init.pp
[snip]

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git push
Counting objects: 728, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (687/687), done.
Writing objects: 100% (728/728), 343.61 KiB | 0 bytes/s, done.
Total 728 (delta 188), reused 0 (delta 0)
remote:
remote: Create merge request for production:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=production
remote:
To ssh://localhost/puppet/control.git
   056f697..5af0cc7  production -> production

```

Now all of our production environment is hosted on our GitLab server.

We've also used some Git commands for the first time

- git checkout
- git pull
- git add
- git commit
- git push

A summary of what we've just done would go like this:

1.  Copy over our entire production codebase to `/share` within our VM
2.  Change directory into our clone of the **puppet/control** Git repository on the host side
3.  Rsync our entire production codebase **from** the `share` directory **to** our **puppet/control** repo
4.  Pull down the latest code from GitLab (with **git pull**) since we created our **production** branch via GitLab's WebGUI
5.  Checkout (switch to) the production branch (with **git checkout production**)
6.  Select our `data/`, `manifests/`, and `modules/` directories to be staged for a commit to our control repo
7.  Commit the staged changes to our control repo (with **git commit**)
8.  Push our local changes to the remote repository hosted within GitLab (with **git push**)

We will look at all of these commands in more depth in the next lab.

Now, Let's do the same thing for the development environment, so it doesn't get left behind...

**But**, let's make one small change:  **Do NOT copy over the `modules/` directory.  We will show how we can use R10K to pull the modules down for us.



```
[root@puppet environments]# mkdir /share/development
[root@puppet environments]# cd /share/development
[root@puppet development]# rsync -acv /etc/puppetlabs/puppet/environments/development/data .
sending incremental file list
data/
data/common.yaml
data/location/
data/location/amsterdam.yaml
data/location/seattle.yaml
data/location/woodinville.yaml
data/node/
data/node/agent.example.com.yaml
data/node/puppet.example.com.yaml
data/role/

sent 1324 bytes  received 142 bytes  2932.00 bytes/sec
total size is 710  speedup is 0.48
[root@puppet development]# rsync -acv /etc/puppetlabs/puppet/environments/development/manifests .
sending incremental file list
manifests/
manifests/common_hosts.pp
manifests/common_packages.pp
manifests/site.pp

sent 2601 bytes  received 73 bytes  5348.00 bytes/sec
total size is 2323  speedup is 0.87
```

We've just copied over our Hiera data and manifests from the **development** environment directory on the puppet master to our temporary `/share` area.

Next, back on the host (outside the VM) we will rsync the files over to our **puppet/control** repo

```
mbp-mark:[/Users/mbentle8] $ cd Documents/Git/Puppet-Training/control
/Users/mbentle8/Documents/Git/Puppet-Training/control

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git branch -a
  master
* production
  remotes/origin/master
  remotes/origin/production
```

Notice that we do not yet have a **development** branch in our **puppet/control** repo.  Let's create it using the **-b** option to **git checkout**

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git checkout -b development
Switched to a new branch 'development'
```

Okay, now copy the `data/` and `manifests/` directories over...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ rsync -acv /Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share/development/* .
building file list ... done
data/
data/common.yaml
data/location/
data/node/
data/node/agent.example.com.yaml
data/role/
manifests/

sent 950 bytes  received 136 bytes  2172.00 bytes/sec
total size is 3033  speedup is 2.79

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ ls -al data
total 8
drwxr-xr-x  6 mbentle8  staff  204 Oct 24 13:06 .
drwxr-xr-x  7 mbentle8  staff  238 Oct 24 15:35 ..
-rw-r--r--  1 mbentle8  staff  157 Oct 24 13:06 common.yaml
drwxr-xr-x  5 mbentle8  staff  170 Oct 24 13:06 location
drwxr-xr-x  5 mbentle8  staff  170 Oct 24 13:17 node
drwxr-xr-x  2 mbentle8  staff   68 Oct 24 13:06 role

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ ls -al manifests
total 24
drwxr-xr-x  5 mbentle8  staff   170 Oct 24 13:06 .
drwxr-xr-x  7 mbentle8  staff   238 Oct 24 15:35 ..
-rw-r--r--  1 mbentle8  staff   447 Oct 24 13:06 common_hosts.pp
-rw-r--r--  1 mbentle8  staff   189 Oct 24 13:06 common_packages.pp
-rw-r--r--  1 mbentle8  staff  1687 Oct 24 13:06 site.pp
```

Next, let's add those files to our commit.

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git add data
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git add manifests
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git status
On branch development
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    modified:   data/common.yaml
    modified:   data/node/agent.example.com.yaml
```

Remember, only files that are different from the **production** branch will be added.  Since we branched off of the **production** branch, we already have all of the files that were in the production branch, and now we are just committing the differences between **development** and **production**

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git commit -a -m 'initial commit'
[development fd2e409] initial commit
 2 files changed, 1 insertion(+), 1 deletion(-)

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ git push
fatal: The current branch development has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin development

mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ git push --set-upstream origin development
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 691 bytes | 0 bytes/s, done.
Total 6 (delta 1), reused 0 (delta 0)
remote:
remote: Create merge request for development:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=development
remote:
To ssh://localhost/puppet/control.git
 * [new branch]      development -> development
Branch development set up to track remote branch development from origin.
```

Boom!  Our development code, less the modules, is now hosted in GitLab.

We now have most of our development environment setup.  We have not copied over the modules, as we will use R10K to do that next...

Let's do another R10K test run from /tmp to see what comes down ...

```
[root@puppet development]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Removing unmanaged path /tmp/r10k-test/development/modules/motd
INFO     -> Removing unmanaged path /tmp/r10k-test/development/modules/ntp
INFO     -> Removing unmanaged path /tmp/r10k-test/development/modules/registry
INFO     -> Removing unmanaged path /tmp/r10k-test/development/modules/stdlib
INFO     -> Removing unmanaged path /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Removing unmanaged path /tmp/r10k-test/production/modules/motd
INFO     -> Removing unmanaged path /tmp/r10k-test/production/modules/ntp
INFO     -> Removing unmanaged path /tmp/r10k-test/production/modules/registry
INFO     -> Removing unmanaged path /tmp/r10k-test/production/modules/stdlib
INFO     -> Removing unmanaged path /tmp/r10k-test/production/modules/timezone

[root@puppet tmp]# tree /tmp/r10k-test/production
/tmp/r10k-test/production
├── data
│   ├── common.yaml
│   ├── location
│   │   ├── amsterdam.yaml
│   │   ├── seattle.yaml
│   │   └── woodinville.yaml
│   └── node
│       ├── agent.example.com.yaml
│       ├── gitlab.example.com.yaml
│       └── puppet.example.com.yaml
├── manifests
│   ├── common_hosts.pp
│   ├── common_packages.pp
│   └── site.pp
├── modules
└── README.md

5 directories, 11 files
[root@puppet tmp]# tree /tmp/r10k-test/development
/tmp/r10k-test/development
├── data
│   ├── common.yaml
│   ├── location
│   │   ├── amsterdam.yaml
│   │   ├── seattle.yaml
│   │   └── woodinville.yaml
│   └── node
│       ├── agent.example.com.yaml
│       ├── gitlab.example.com.yaml
│       └── puppet.example.com.yaml
├── manifests
│   ├── common_hosts.pp
│   ├── common_packages.pp
│   └── site.pp
├── modules
└── README.md

5 directories, 11 files

```

See how R10K pulled down our code and dropped it in /tmp/r10k-test as per our r10k.yaml ?

Did you notice that R10K was so rude and just removed our modules?!?!  Hey!

R10K will wipe away any files within the environment that are not managed by R10K.  So how to we tell R10K we want those modules?

We need to do one more thing before we can swing it over to the final location of `/etc/puppetlabs/puppet/environments`

We need to get the **modules/** directory populated the same way as on the master currently

Look at what's in the production environment modules directory right now:

```
[root@puppet tmp]# cd /etc/puppetlabs/puppet/environments/production/
[root@puppet production]# tree -L 1 modules
modules
├── motd
├── ntp
├── registry
├── stdlib
└── timezone

5 directories, 0 files
```

What versions of those modules are we running?

```
[root@puppet production]# puppet module list --environment=development
/etc/puppetlabs/puppet/environments/development/modules
├── puppetlabs-motd (v1.4.0)
├── puppetlabs-ntp (v4.2.0)
├── puppetlabs-registry (v1.1.3)
├── puppetlabs-stdlib (v4.9.1)
└── saz-timezone (v3.3.0)
/etc/puppetlabs/puppet/modules
└── puppetlabs-stdlib (v4.10.0)
```

There's 5 modules in there.  Before we tell R10K to pull code in to `/etc/puppetlabs/puppet/environments` we need to make sure the modules are pulled down, otherwise our puppet runs will break.

There's another feature of R10K that allows us to specify other Git repositories to pull modules from.  To control this, we create a config file called a **Puppetfile**.

Back on your workstation in your **puppet/control** repo, create a **Puppetfile** at the top level

Put these lines in your Puppetfile (in the **development** branch)

```
moduledir 'modules'
mod 'puppetlabs/motd',     'v1.4.0'
mod 'puppetlabs/ntp',      'v4.2.0'
mod 'puppetlabs/registry', 'v1.1.3'
mod 'puppetlabs/stdlib',   'v4.9.1'
mod 'saz/timezone',        'v3.3.0'
```
Save, add, commit, and push your new Puppetfile ...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ vi Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git add Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)*$ git commit -a -m 'initial commit'
[development 4ad9bb1] initial commit
 1 file changed, 7 insertions(+)
 create mode 100644 Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 384 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Create merge request for development:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=development
remote:
To ssh://localhost/puppet/control.git
   fd2e409..4ad9bb1  development -> development
```

And re-run r10k from your puppet master...

```
[root@puppet production]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Deploying module /tmp/r10k-test/development/modules/motd
INFO     -> Deploying module /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying module /tmp/r10k-test/development/modules/registry
INFO     -> Deploying module /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying module /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Deploying environment /tmp/r10k-test/production
```

Notice how R10K pulled down all of the modules we specified in the **development** branch'es **Puppetfile**?  Pretty cool, eh?

Next let's copy our **development** `Puppetfile` in to the **production** branch, so that our **production** environment gets the modules as well.
Remember that the production environment may have differing version of the modules.  Let's look...

```
[root@puppet tmp]# puppet module list --environment=production
/etc/puppetlabs/puppet/environments/production/modules
├── puppetlabs-motd (v1.4.0)
├── puppetlabs-ntp (v4.2.0)
├── puppetlabs-registry (v1.1.3)
├── puppetlabs-stdlib (v4.13.1)
└── saz-timezone (v3.3.0)
[snip]
```

Take note that only the **puppetlabs-stdlib** module is different in the **production** environment.

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (development)$ git checkout production
Switched to branch 'production'
Your branch is up-to-date with 'origin/production'.
```

We switch to the **production** branch, getting ready to create/edit the Puppetfile in that branch...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git diff --stat development
 Puppetfile                       | 7 -------
 data/common.yaml                 | 1 +
 data/node/agent.example.com.yaml | 1 -
 3 files changed, 1 insertion(+), 8 deletions(-)
```

Notice that the development branch has 3 differeing files, one of which is the Puppetfile.
Remember, we've created a Puppetfile in the **development** branch, but not the **production** branch.
Let's simply checkout the development branch'es Puppetfile in to the **production** branch (which is our current branch) and edit it...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git checkout development Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ vi Puppetfile
```

Edit the production Puppetfile so that stdlib has the matching version...

```
moduledir 'modules'
mod 'puppetlabs/motd',     'v1.4.0'
mod 'puppetlabs/ntp',      'v4.2.0'
mod 'puppetlabs/registry', 'v1.1.3'
mod 'puppetlabs/stdlib',   'v4.13.1'
mod 'saz/timezone',        'v3.3.0'
```

Save it, add it, commit and push it...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git add Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)*$ git commit -a -m 'initial commit'
[production 629dfa0] initial commit
 1 file changed, 7 insertions(+)
 create mode 100644 Puppetfile
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 384 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Create merge request for production:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=production
remote:
To ssh://localhost/puppet/control.git
   5af0cc7..629dfa0  production -> production
```

Now let's run R10K again, and see if we get everything...

```
[root@puppet tmp]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Deploying module /tmp/r10k-test/development/modules/motd
INFO     -> Deploying module /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying module /tmp/r10k-test/development/modules/registry
INFO     -> Deploying module /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying module /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Deploying module /tmp/r10k-test/production/modules/motd
INFO     -> Deploying module /tmp/r10k-test/production/modules/ntp
INFO     -> Deploying module /tmp/r10k-test/production/modules/registry
INFO     -> Deploying module /tmp/r10k-test/production/modules/stdlib
INFO     -> Deploying module /tmp/r10k-test/production/modules/timezone
```

Looks good, all except for that **master** environment in there.  Since Git creates the **master** branch by default, and we dont need or want a **master** Puppet Environment, we should delete that branch from our Git repository.  If we dont, we'll end up with a **master** environment on our Puppet Master.  It wont hurt anything, but will be annoying.

Delete the **local master branch** with: `git branch -d master`

Delete the **remote master branch** with: `git push origin --delete master`

Try it now...

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git branch -a
  development
  master
* production
  remotes/origin/development
  remotes/origin/master
  remotes/origin/production
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git branch -d master
Deleted branch master (was 056f697).
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
remote: GitLab: You are not allowed to delete protected branches from this project.
To ssh://localhost/puppet/control.git
 ! [remote rejected] master (pre-receive hook declined)
error: failed to push some refs to 'ssh://localhost/puppet/control.git'
```

Okay, darn.  Normally that would work, but our **master** branch is **protected**.  Let's go into the GitLab WebGUI and figure out how to un-protect it.

- Go to the **Settings** gear icon, and select **Protected Branches**
- Add **production** as a protected branch
- Click **Unprotect** for the **master** branch
- Now let's re-try our **git push**

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
remote: error: By default, deleting the current branch is denied, because the next
remote: error: 'git clone' won't result in any file checked out, causing confusion.
remote: error:
remote: error: You can set 'receive.denyDeleteCurrent' configuration variable to
remote: error: 'warn' or 'ignore' in the remote repository to allow deleting the
remote: error: current branch, with or without a warning message.
remote: error:
remote: error: To squelch this message, you can set it to 'refuse'.
remote: error: refusing to delete the current branch: refs/heads/master
To ssh://localhost/puppet/control.git
 ! [remote rejected] master (deletion of the current branch prohibited)
error: failed to push some refs to 'ssh://localhost/puppet/control.git'
```

Hmmm, not sure why it thinks the current branch is **master**.  I clearly have the **production** branch checked out.  Let's try deleting the branch via the WebGUI instead.

Ahh, I see.  The **master** branch is still configured as the **default** branch within GitLab.  Go into the Project Settings, and change the default branch to **production**

```
mbp-mark:[/Users/mbentle8/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
To ssh://localhost/puppet/control.git
 - [deleted]         master
```

Okay, re-run R10K again...

```
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Deploying module /tmp/r10k-test/development/modules/motd
INFO     -> Deploying module /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying module /tmp/r10k-test/development/modules/registry
INFO     -> Deploying module /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying module /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Deploying module /tmp/r10k-test/production/modules/motd
INFO     -> Deploying module /tmp/r10k-test/production/modules/ntp
INFO     -> Deploying module /tmp/r10k-test/production/modules/registry
INFO     -> Deploying module /tmp/r10k-test/production/modules/stdlib
INFO     -> Deploying module /tmp/r10k-test/production/modules/timezone
INFO     -> Removing unmanaged path /tmp/r10k-test/master
```

Notice that the un-used **master** directory environment was removed?  That's what we want.

## Put R10K in control

Finally!

Update the **r10k.yaml** so that **basedir** points to the real PE environments dir like this:

```yaml
---
cachedir: '/var/cache/r10k'

sources:
  puppet-training:
    remote:  'git@gitlab:puppet/control'
    basedir: '/etc/puppetlabs/puppet/environments'
```

Now, when we run r10k, it will completely wipe anything in the basedir, and then pull everything in exactly like we were doing into our test dir... Let's go ahead and do that...

```
[root@puppet ~]# cd /etc/puppetlabs/r10k
[root@puppet r10k]# vi r10k.yaml
[root@puppet r10k]#  r10k deploy environment -vp
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

Now do a test puppet run on both the puppet master and the gitlab VM, and you should still get a clean run...

```
[root@puppet r10k]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for puppet.example.com
Info: Applying configuration version '1477421035'
Notice: Location is: seattle
Notice: /Stage[main]/Main/Notify[Location is: seattle]/message: defined 'message' as 'Location is: seattle'
Notice: /Stage[main]/Motd/File[/etc/motd]/content:
--- /etc/motd    2016-10-25 11:21:08.909881206 -0700
+++ /tmp/puppet-file20161025-11442-14gzxsg    2016-10-25 11:44:07.985535531 -0700
@@ -1,7 +1,7 @@

 ###########################################################################
 The operating system is CentOS
-The free memory is 1.27 GB
+The free memory is 1.14 GB
 The domain is example.com
 ###########################################################################


Notice: /Stage[main]/Motd/File[/etc/motd]/content: content changed '{md5}e3a4503b85260742a40fcb4919f268fd' to '{md5}1165160442ec2b0f6452d3949ca5c69f'
Notice: Finished catalog run in 5.18 seconds
```

Great, good run on the puppet master!

```
[root@gitlab ~]# puppet agent -t
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for gitlab.example.com
Info: Applying configuration version '1477421188'
Notice: Location is: amsterdam
Notice: /Stage[main]/Main/Notify[Location is: amsterdam]/message: defined 'message' as 'Location is: amsterdam'
Notice: /Stage[main]/Motd/File[/etc/motd]/content:
--- /etc/motd    2016-10-25 11:21:39.149385036 -0700
+++ /tmp/puppet-file20161025-12252-dey5j8    2016-10-25 11:46:31.225490536 -0700
@@ -1,7 +1,7 @@

 ###########################################################################
 The operating system is CentOS
-The free memory is 224.97 MB
+The free memory is 188.94 MB
 The domain is example.com
 ###########################################################################


Notice: /Stage[main]/Motd/File[/etc/motd]/content: content changed '{md5}c3872150447cb9d74fbb7c9c3cb03263' to '{md5}a7d83fc90aa7d16498e0e99be17967f4'
Notice: Finished catalog run in 1.95 seconds
```

Good run on the GitLab agent node as well!

If you also have the **agent** VM up and running, you should get a clean run on it as well.

## Cleanup

Remember that we used the `share/` directory as a temporary staging directory.  Let's clean that up so Git doesn't bug us about untracked files there...

```
mbp-mark:[/Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/tutorial/vbox] (master)*$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Untracked files:
  (use "git add <file>..." to include in what will be committed)

    ../../share/development/
    ../../share/production/

nothing added to commit but untracked files present (use "git add" to track)
mbp-mark:[/Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/tutorial/vbox] (master)*$ cd ../../share
mbp-mark:[/Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share] (master)*$ ls -al
total 8
drwxr-xr-x   6 mbentle8  staff  204 Oct 25 10:41 .
drwxr-xr-x  15 mbentle8  staff  510 Oct 20 15:25 ..
-rw-r--r--   1 mbentle8  staff  137 Oct 19 14:02 README.md
drwxr-xr-x   4 mbentle8  staff  136 Oct 25 10:42 development
drwxr-xr-x   5 mbentle8  staff  170 Oct 24 15:33 production
drwxr-xr-x   7 mbentle8  staff  238 Oct 19 14:02 software
mbp-mark:[/Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share] (master)*$ rm -rf development production
mbp-mark:[/Users/mbentle8/Documents/Git/BitBucket/puppet-training-pe/share] (master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```




## Git post-receive hook

Let's setup a **post-receive hook** which will ssh from GitLab to the puppet master and run r10k for us.
This way, every time we do a **git push** to GitLab, it will automatically run R10K on the master for us.

There's more than one way to do this:

1. setup the *git* account as an MCollective client, and use the r10k module to enable the 'mco r10k sync' command
2. setup ssh keys to allow the git user to run commands on the puppet master password-less
3. configure webhook (don't know how, and wont take the time right now)
4. other?

We will setup SSH keys.  Make sure you **trust** the GitLab server, as we will
be giving it the ability to ssh in as root on our puppet master!

On the GitLab VM...

```
root@gitlab ~]# cd /var/opt/gitlab/git-data/repositories/puppet/control.git
[root@gitlab control.git]# mkdir custom_hooks
[root@gitlab control.git]# cd custom_hooks/
```
Make a bash script called **post-receive** with this content:

```
#!/bin/bash

# List of Puppet Masters to update
pe_masters="
puppet"

PATH="/opt/gitlab/bin:/opt/gitlab/embedded/bin:/opt/gitlab/embedded/libexec/git-core:/opt/puppet/bin:/opt/puppet/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
export PATH

echo
echo "Running post-receive hook..."
for pm in $pe_masters ; do
  ssh -l root $pm "echo \"[$pm] Updating...\" ; /opt/puppet/bin/r10k deploy environment -p ; echo \"[$pm] Done.\""
done
echo

```

All that does is iterate through a list of puppet masters, and ssh as root to each one and run r10k.
(We only have one puppet master in our training environment, but most production environments would have 2 or more for load-balancing.)

Become the git user, create and ssh key pair, and then copy the public key to the root user's ~/.ssh/authorized_keys on the puppet master...

```
[root@gitlab ~]# su - git
Last login: Wed Mar 16 12:47:07 PDT 2016 on pts/0
-sh-4.2$ ls -al .ssh
total 8
drwx------  2 git  git    55 Mar  9 13:35 .
drwxr-xr-x 13 root root 4096 Mar  9 10:59 ..
-rw-------  1 git  git  1087 Mar  9 14:58 authorized_keys
-rw-r--r--  1 git  git     0 Mar  9 14:58 authorized_keys.lock
-sh-4.2$ pwd
/var/opt/gitlab
-sh-4.2$ ssh-keygen -t rsa -b 2048 -N ''
Generating public/private rsa key pair.
Enter file in which to save the key (/var/opt/gitlab/.ssh/id_rsa):
Your identification has been saved in /var/opt/gitlab/.ssh/id_rsa.
Your public key has been saved in /var/opt/gitlab/.ssh/id_rsa.pub.
The key fingerprint is:
6a:05:5c:80:75:80:c9:c9:df:44:98:a7:c6:be:ab:5b git@gitlab
The key's randomart image is:
+--[ RSA 2048]----+
|   o *+*+        |
|    B.ooo        |
|     oo=         |
|      =..        |
|     o  S        |
|      .o         |
|      E.         |
|     o.          |
|    oo..         |
+-----------------+
-sh-4.2$ ls -al .ssh
total 16
drwx------  2 git  git    85 Mar 16 12:55 .
drwxr-xr-x 13 root root 4096 Mar  9 10:59 ..
-rw-------  1 git  git  1087 Mar  9 14:58 authorized_keys
-rw-r--r--  1 git  git     0 Mar  9 14:58 authorized_keys.lock
-rw-------  1 git  git  1679 Mar 16 12:55 id_rsa
-rw-r--r--  1 git  git   392 Mar 16 12:55 id_rsa.pub
-sh-4.2$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQqKmxWCjcBllO+BnZLVRd+rhzXlm/6S5ccspvbeBEH/zST5DhKNGLwtJn0yz8u1cWyYztkyjZIPwuJzBbap3vU/Lx6juVaoAUK8AnDIeCY+nZFN6oZaSfpBEJunno1FPlVVja1sCoYSMqmsnCY/kcLawq3ui9zdx25NFWc7hG9jOqUcmIdJgGFcy5/GsCgJtKvS/UkJ22xaxKWKJMHT0/KHb+0mw/RClhqWsJD9PFI0+Psnh/D2XFuG7eoZooenSFV3bVQoWe5AgwNIX5/B0/0xlUWcPjTyWfa7MhffHTCmTzUauEytkqScfH3ArtBNL6vRd8uCPi7pTrRFwo9jWl git@gitlab
```

Add that public key to root's ~root/.ssh/authorized_keys file on the master, and `chmod 600 ~root/.ssh/authorized_keys`

One the puppet master...

```
[root@puppet .ssh]# echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQqKmxWCjcBllO+BnZLVRd+rhzXlm/6S5ccspvbeBEH/zST5DhKNGLwtJn0yz8u1cWyYztkyjZIPwuJzBbap3vU/Lx6juVaoAUK8AnDIeCY+nZFN6oZaSfpBEJunno1FPlVVja1sCoYSMqmsnCY/kcLawq3ui9zdx25NFWc7hG9jOqUcmIdJgGFcy5/GsCgJtKvS/UkJ22xaxKWKJMHT0/KHb+0mw/RClhqWsJD9PFI0+Psnh/D2XFuG7eoZooenSFV3bVQoWe5AgwNIX5/B0/0xlUWcPjTyWfa7MhffHTCmTzUauEytkqScfH3ArtBNL6vRd8uCPi7pTrRFwo9jWl git@gitlab' >> ~root/.ssh/authorized_keys

[root@puppet .ssh]# chmod 600 ~root/.ssh/authorized_keys
```

Now test sshing from the git@gitlab account to root@puppet ...

```
-sh-4.2$ whoami
git

-sh-4.2$ ssh -l root puppet
The authenticity of host 'puppet (192.168.198.10)' can't be established.
ECDSA key fingerprint is 39:e5:9b:0d:8b:bd:74:0a:12:e8:c6:37:cb:cf:17:c3.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'puppet,192.168.198.10' (ECDSA) to the list of known hosts.
Last login: Wed Mar 16 12:27:24 2016 from 192.168.198.11
[root@puppet ~]#
[root@puppet ~]# exit
logout
Connection to puppet closed.
```

Now we should be able to ssh without being prompted at all...

```
-sh-4.2$ ssh -l root puppet 'hostname;id'
puppet
uid=0(root) gid=0(root) groups=0(root)
```

Now our post-receive hook will ssh to the master and run r10k automatically...

The next time you make a change in your control repo, commit, and push, you should see something like this:

```
[/Users/Mark/Git/Puppet-Training/control/data/node] (production)$ git push
Counting objects: 1, done.
Writing objects: 100% (1/1), 188 bytes | 0 bytes/s, done.
Total 1 (delta 0), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   f193b1d..625fe7e  production -> production
```

## Summary

So what have we done?

1. Created SSH key for the root user
  - Puppet runs as root, so this key is used by puppet/R10K to pull from GitLab
2. Installed SSH key as **Deploy Key** in GitLab for puppet/control
  - This allows the root user to clone/pull that repo
3. Created a new branch called **production** in our control repo
4. Moved our existing Puppet code and Hiera data in to GitLab
5. Configured R10K to pull our Puppet code and Hiera data down to the Puppet Master
  - This includes configuring the **Puppetfile** to download the modules we use
6. Configured a **post-receive** hook on the GitLab server
  - This will trigger an R10K run on the puppet master when we do a **git push**

## REMINDER - No more editing Puppet code directly on the Puppet Master

From this point going forward we will **NOT** edit any code files directly on the Puppet Master.
Instead, we will edit our code and Hiera data on our workstation in our **puppet/control** repo.

In the next section we will look at Git in more detail, but the basic process going forward will be:

1.  Edit file(s) in your local clone of the puppet/control repo
2.  Add/Commit new or changed file(s)
3.  Push to the remote puppet/control repo hosted in/on GitLab

That's it!

---

Continue on to **Lab #11** --> [Roles & Profiles](11-Roles-and-Profiles.md#lab-11)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley


