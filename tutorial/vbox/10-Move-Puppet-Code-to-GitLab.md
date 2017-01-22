<-- [Back](09-Install-GitLab.md#lab-9)

---

### **Lab #10** - Move Puppet Code Under GitLab Control

---

### Overview

We've just setup GitLab in [Lab #9](09-Install-GitLab.md#lab-9) and now we
want to be able to use it.  We've already written some puppet code, and it's
currently sitting in `/etc/puppetlabs/code/environments` on our puppet
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

But first, let's talk a bit more about Git commands and concepts...

### Some Git commands and concepts

What is a **Push**? **Pull**? What does it mean to **"clone a repo"**?  What is Git exactly?
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

### Git Concept: The Git Repository

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

### Git Command:  git clone

To make a complete copy of a remote repo, you can use `git clone <URL>`

- It makes an exact clone of the remote Git repository.
- Git will also setup a **remote** for pushing to and pulling from
- Git will also configure this remote as a **tracking branch**

The **remote** is just a meaningful name given to the remote URL which you can refer
to with other git commands.  Git will setup a remote with the name **origin** by default.

Type `git remote -v` to see the configured remote of your control repo.

Git will also use **origin** as the default for other commands if you don't
specify a remote.

### Git Command: git status

The `git status` command is useful for telling you what branch you're on, as
well as the status of the staging area.  When you make changes to files that
Git is tracking, it will notice that, and show you that it noticed.

### Git Concept: The Staging Area

Git has something called a **"Staging Area"** (sometimes referred to as
**"The Index"**).  It's where we can "stage" our changes in preperation
to permanently commit them to the repo.  Once you commit a change, it's
there forever in the commit history.

### Git Command: git add

To add a file to the staging area, use the `git add` command.  We can use
this command to add files to the staging area prior to commiting them.

### Git Command: git commit

Now that we're run the `git add` on a file, and the `git status` shows that
it's staged (ready to be committed), we can go ahead and either:

1. commit the change
2. un-stage the change

A typical commit would look like this:  `git commit -m 'some comment'`

The **-m** option is short for **commit message** and is just a descriptive message
to go along with the commit in case we need to find it in the future, the message
should make it easier to identify later what changes were made

### Git Command: git push

Remember earlier we looked at `git clone` and mentioned that when we clone a
repo, Git will automatically setup the remote tracking branch.  Git is comparing
our repo's branch with what it knows about the remote repo's branch, and it will
notice when we have made a new commit, but the remote doesn't yet have that commit.

We need to `git push` to send our local commits to the remote repository.

### Git Command: git pull

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

### Git Concept: Git Branches

Although we've seen **branches** a little bit (e.g. **production branch**) we've
not really talked about what a branch is.  Git allows us to spin off a copy of
our repo, makes changes within that copy (called a branch), and then either
merge our changes up to the parent branch, or discard our changes.  This idea
becomes very useful when making changes to puppet code without affecting the
production environment, but still allowing us to test our code.

### Git Command: git checkout

The easiest way to create a new branch is to use `git checkout -b <branch-name>`

It's a shortcut for creating a branch, and then checking out that branch.

The longer version would be a `git branch <branch-name>`
followed by `git checkout <branch-name>` but why type all of that?

### Okay, shifting gears...

With these Git concepts and commands in mind, let's work on getting our existing
Puppet code into GitLab (our Git hosting server).

GitLab provides the authentication/authorization framework around our puppet/control repo.
We've previously setup our own account, and cloned the puppet/control repo to our
workstation, but we will also need to allow the root user on our puppet master access
to clone the control repo as well, as this repo is where we will store some of our
puppet code and hiera data.

### Let's Setup root SSH access to GitLab

Since Puppet runs as root, and needs to pull code out of GitLab, we need to configure
the root account on our Puppet Master with read-only access to the control repo.

Once this is done, we
will take advantage of a **puppet.conf** config item called **postrun_command** which
will run a command or script after every Puppet agent run.  Since the Puppet agent
runs every 30 minutes, so would our postrun_command.  We will set our postrun_command
to run R10K.  It goes like this:

- Puppet executes the **postrun_command** as root every 30 minutes (by default)
- We use **postrun_command** to run `r10k` to build puppet environments from Git branches
- R10K uses the git command to clone and pull repos down to the puppet master
- The git command will use ssh keys to authenticate with the GitLab server

So, if we want to use R10K to pull our code down, we need to give root the ability
to use git to pull code from our gitlab host.

Let's setup the **root** user on the puppet master to be able to
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

- Go to your **[puppet/control](http://127.0.0.1:24080/puppet/control)** project (repo)
- Find and click the **'Settings Gear Icon'** (should be in top/right)
- Click on **[Deploy Keys](http://127.0.0.1:24080/puppet/control/deploy_keys)**
- Enter a meaningful title like **'Used by R10K to pull from GitLab'**
- Copy the **public key** you just generated from `/root/.ssh/id_rsa.pub` on your puppet master
- Paste the key in to the **Key** dialog box
- Save it by clicking **'Add Key'**

At this point, the root user on the **puppet* VM should be able to clone the repo.

### Test that the root user can clone the puppet/control repo

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

### Create new branch called 'production'

In the GitLab webGUI, create a new branch called 'production'

- Navigate back to your **[puppet/control](http://127.0.0.1:24080/puppet/control)**
- Click the **+** icon (Plus sign) and select **New Branch**
- Enter **production** created from **master**

We now have 2 branches in our puppet/control repo

- master
- production

We will eventually delete the **master** branch, and use **production** as its replacement.
We dont want **'master'** as we do not have a master puppet environment.  We do have a
**production** puppet environment, so that's why we want a production **branch**

### Test that R10K can pull down your code

R10K knows to look for its config file in `/etc/puppetlabs/r10k/`

```
[root@puppet ~]# cd /etc/puppetlabs/r10k
[root@puppet r10k]# vi r10k.yaml
```

Create an `/etc/puppetlabs/r10k/r10k.yaml` containing the following:

```yaml
---
cachedir: '/var/cache/r10k'

sources:
  puppet-tutorial:
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
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Environment master is now at 3e6627e116e24bbdf7e4d24b24d67d4aa586634e
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Environment production is now at 3e6627e116e24bbdf7e4d24b24d67d4aa586634e
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

### Let's Move Our Existing Puppet Code In To GitLab

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

1. On your **puppet** VM,  identify the files we need (within `/etc/puppetlabs/code/environments`)
2. Copy those files over to `/share` (still within the VM)
3. Then in another terminal window, on the host side, copy from your `puppet-tutorial-pe/share` directory...
4. ...to the location of your clone of the **puppet/control** repo

So, in my case, this 2-stage copy will look like this:

**Stage 1**:  On my puppet master VM, Copy each environment directory...
```
   From: /etc/puppetlabs/code/environments
   To:   /share
```
**Stage 2**: On my host workstation, Copy each environment directory...
```
   From: /Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share
   To:   /Users/bentlema/gitlab/puppet/control
```

Note that when we get to the **Stage 2** copy, we eliminate the actual
environment directory name, and instead ensure that the proper **Git Branch**
is **checked out** when we copy.  We will be copying the **production/** directory
over to the **production branch** within our Git repo, and likewise for the
**development/** directory and branch.

So within the **puppet** VM I'm going to start by copying the **production**
environment over to `/share`

```
[root@puppet ~]# cd /etc/puppetlabs/code/environments
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
# Check where we are at (our current working dir)
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ pwd
/Users/bentlema/gitlab/puppet/control

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ ls -al
total 8
drwxr-xr-x   4 bentlema  staff  136 Nov 16 12:27 .
drwxr-xr-x   3 bentlema  staff  102 Nov 16 12:23 ..
drwxr-xr-x  13 bentlema  staff  442 Nov 16 13:34 .git
-rw-r--r--   1 bentlema  staff   12 Nov 16 12:27 README.md

# Take a peek at the dir we will be copying from
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ ls -al /Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share
total 32
drwxr-xr-x   6 bentlema  staff   204 Nov 16 13:34 .
drwxr-xr-x  15 bentlema  staff   510 Nov 16 07:56 ..
-rw-r--r--@  1 bentlema  staff  8196 Nov 11 14:07 .DS_Store
-rw-r--r--   1 bentlema  staff   137 Nov 11 10:50 README.md
drwxr-xr-x   6 bentlema  staff   204 Nov 16 13:34 production
drwxr-xr-x   8 bentlema  staff   272 Nov 11 13:01 software

# Okay, we see the production directory we just copied over within our VM
# Let's checkout the production branch, and copy the production code over to it

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ git checkout production
error: pathspec 'production' did not match any file(s) known to git.

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ git pull
From ssh://localhost/puppet/control
 * [new branch]      production -> origin/production
Already up-to-date.

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (master)$ git checkout production
Branch production set up to track remote branch production from origin.
Switched to a new branch 'production'

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ rsync -acv /Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share/production/* .
building file list ... done
environment.conf
hieradata/
hieradata/common.yaml
hieradata/location/
hieradata/location/amsterdam.yaml
hieradata/location/seattle.yaml
hieradata/location/woodinville.yaml
hieradata/node/
hieradata/node/agent.example.com.yaml
hieradata/node/gitlab.example.com.yaml
hieradata/node/puppet.example.com.yaml
hieradata/role/
manifests/
manifests/common_hosts.pp
manifests/common_packages.pp
manifests/site.pp
[snip]
sent 1179660 bytes  received 15020 bytes  2389360.00 bytes/sec
total size is 1122664  speedup is 0.94


mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ ls -al
total 16
drwxr-xr-x   8 bentlema  staff  272 Nov 16 13:42 .
drwxr-xr-x   3 bentlema  staff  102 Nov 16 12:23 ..
drwxr-xr-x  15 bentlema  staff  510 Nov 16 13:43 .git
-rw-r--r--   1 bentlema  staff   12 Nov 16 12:27 README.md
-rw-r--r--   1 bentlema  staff  879 Nov 16 13:34 environment.conf
drwxr-xr-x   6 bentlema  staff  204 Nov 16 13:34 hieradata
drwxr-xr-x   5 bentlema  staff  170 Nov 16 13:34 manifests
drwxr-xr-x   7 bentlema  staff  238 Nov 16 13:34 modules

```

Okay, we just copied over the entire production environment (Hiera data, manifests and modules) to our clone of the control repo.

Next we need to commit it to our Git repo...

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git add environment.conf
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git add hieradata
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git add manifests
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git add modules

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git commit -m 'initial add of production env'
[production 1ead2c1] initial add of production env
 654 files changed, 31627 insertions(+)
 create mode 100644 environment.conf
 create mode 100644 hieradata/common.yaml
 create mode 100644 hieradata/location/amsterdam.yaml
 create mode 100644 hieradata/location/seattle.yaml
 create mode 100644 hieradata/location/woodinville.yaml
 create mode 100644 hieradata/node/agent.example.com.yaml
 create mode 100644 hieradata/node/gitlab.example.com.yaml
 create mode 100644 hieradata/node/puppet.example.com.yaml
 create mode 100644 manifests/common_hosts.pp
 create mode 100644 manifests/common_packages.pp
 create mode 100644 manifests/site.pp
[snip]

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ git push
Counting objects: 741, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (704/704), done.
Writing objects: 100% (741/741), 346.73 KiB | 0 bytes/s, done.
Total 741 (delta 186), reused 0 (delta 0)
remote:
remote: Create merge request for production:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=production
remote:
To ssh://localhost/puppet/control.git
   3e6627e..1ead2c1  production -> production

```

Now all of our production environment is hosted on our GitLab server.

We've also used some Git commands for the first time

- git checkout
- git pull
- git add
- git commit
- git push

A summary of what we've just done would go like this:

1.  We copied over our entire production codebase to `/share` within our VM
2.  Changed directory into our clone of the **puppet/control** Git repository on the host side
3.  Rsync'ed our entire production codebase **from** the `share/` directory **to** our **puppet/control** repo
4.  Pulled down the latest code from GitLab (with **git pull**) since we created our **production** branch via GitLab's WebGUI
5.  Checked out (switched to) the production branch (with **git checkout production**)
6.  Selected our `hieradata/`, `manifests/`, and `modules/` directories to be staged for a commit to our control repo
7.  Commited the staged changes to our control repo (with **git commit**)
8.  Pushed our local changes to the remote repository hosted within GitLab (with **git push**)

We will look at all of these commands in more depth in the next lab.

Now, Let's do the same thing for the development environment, so it doesn't get left behind...

**But**, let's make one small change:  **Do NOT copy over the `modules/` directory.  We will show how we can use R10K to pull the modules down for us.



```
[root@puppet environments]# mkdir /share/development
[root@puppet environments]# cd /share/development
[root@puppet development]# rsync -acv /etc/puppetlabs/code/environments/development/hieradata .
[root@puppet development]# rsync -acv /etc/puppetlabs/code/environments/development/manifests .
```

We've just copied over our Hiera data and manifests from the **development** environment directory on the puppet master to our temporary `/share` area.

Next, back on the host (outside the VM) we will rsync the files over to our **puppet/control** repo

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ git branch -a
  master
* production
  remotes/origin/master
  remotes/origin/production
```

Notice that we do not yet have a **development** branch in our **puppet/control**
repo.  Rather than creating a new branch via the GitLab WebGUI, let's create it
using the **-b** option to **git checkout**

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ git checkout -b development
Switched to a new branch 'development'
```

Okay, now copy the `hieradata/` and `manifests/` directories over...

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$ rsync -acv /Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share/development/* .
building file list ... done
hieradata/
hieradata/common.yaml
hieradata/location/
hieradata/node/
hieradata/node/agent.example.com.yaml
hieradata/role/
manifests/

sent 950 bytes  received 136 bytes  2172.00 bytes/sec
total size is 2650  speedup is 2.44

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ ls -al hieradata
total 8
drwxr-xr-x  6 bentlema  staff  204 Nov 15 14:57 .
drwxr-xr-x  8 bentlema  staff  272 Nov 16 13:42 ..
-rw-r--r--  1 bentlema  staff  153 Nov 15 14:57 common.yaml
drwxr-xr-x  5 bentlema  staff  170 Nov 15 14:57 location
drwxr-xr-x  5 bentlema  staff  170 Nov 15 15:12 node
drwxr-xr-x  2 bentlema  staff   68 Nov 15 14:57 role

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ ls -al manifests
total 24
drwxr-xr-x  5 bentlema  staff   170 Nov 15 14:57 .
drwxr-xr-x  8 bentlema  staff   272 Nov 16 13:42 ..
-rw-r--r--  1 bentlema  staff   446 Nov 15 14:57 common_hosts.pp
-rw-r--r--  1 bentlema  staff   189 Nov 15 14:57 common_packages.pp
-rw-r--r--  1 bentlema  staff  1326 Nov 15 14:57 site.pp
```

Next, let's add those files to our commit.

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git add hieradata
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git add manifests
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git status
On branch development
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    modified:   hieradata/common.yaml
    modified:   hieradata/node/agent.example.com.yaml
```

Remember, only files that are different from the **production** branch will be added.  Since we branched off of the **production** branch, we already have all of the files that were in the production branch, and now we are just committing the differences between **development** and **production**

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git commit -a -m 'initial commit'
[development 6852c44] initial commit
 2 files changed, 1 insertion(+), 1 deletion(-)
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$ git push
fatal: The current branch development has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin development

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$     git push --set-upstream origin development
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 615 bytes | 0 bytes/s, done.
Total 6 (delta 2), reused 0 (delta 0)
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
[root@puppet tmp]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Environment development is now at 6852c44ba61c9d2a4cd10338fcd490544a859a70
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Environment master is now at 3e6627e116e24bbdf7e4d24b24d67d4aa586634e
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Environment production is now at 1ead2c1cf2e6c94484134912a66b9cde1b20db70
```

See how R10K pulled down our code and dropped it in /tmp/r10k-test as per our r10k.yaml ?

We need to do one more thing before we can swing it over to the final location of `/etc/puppetlabs/code/environments`

We need to get the **modules/** directory populated the same way as on the master currently

Look at what's in the production environment modules directory right now:

```
[root@puppet tmp]# cd /etc/puppetlabs/code/environments/production/
[root@puppet production]#  tree -L 1 modules
modules
├── motd
├── ntp
├── registry
├── stdlib
└── timezone

5 directories, 0 files
```

What versions of those modules are we running in the development environment?

```
[root@puppet production]# puppet module list --environment=development
/etc/puppetlabs/code/environments/development/modules
├── puppetlabs-motd (v1.4.0)
├── puppetlabs-ntp (v6.0.0)
├── puppetlabs-registry (v1.1.3)
├── puppetlabs-stdlib (v4.13.1)
└── saz-timezone (v3.3.0)
/etc/puppetlabs/code/modules
└── puppetlabs-stdlib (v4.12.0)
```

There's 5 modules in there.  Before we tell R10K to pull code in to `/etc/puppetlabs/code/environments` we need to make sure the modules are pulled down, otherwise our puppet runs will break.

There's another feature of R10K that allows us to specify other Git repositories to pull modules from.  To control this, we create a config file called a **Puppetfile**.

Back on your workstation in your **puppet/control** repo, create a **Puppetfile** at the top level

Put these lines in your Puppetfile (in the **development** branch)
(Change the versions to match what you have on your VM)

```
moduledir 'modules'
mod 'puppetlabs/motd',     '1.4.0'
mod 'puppetlabs/ntp',      '6.0.0'
mod 'puppetlabs/registry', '1.1.3'
mod 'puppetlabs/stdlib',   '4.13.1'
mod 'saz/timezone',        '3.3.0'
```

Save, add, commit, and push your new Puppetfile ...

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$ vi Puppetfile
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git add Puppetfile
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)*$ git commit -a -m 'initial commit'
[development bcde4e5] initial commit
 1 file changed, 6 insertions(+)
 create mode 100644 Puppetfile
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 388 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Create merge request for development:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=development
remote:
To ssh://localhost/puppet/control.git
   6852c44..bcde4e5  development -> development
```

And re-run r10k from your puppet master...

```
[root@puppet production]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Environment development is now at cb26335eb5c41c808979a5e13f51b41715ceb4f7
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/motd
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/registry
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Environment master is now at 3e6627e116e24bbdf7e4d24b24d67d4aa586634e
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Environment production is now at 1ead2c1cf2e6c94484134912a66b9cde1b20db70

```

Notice how R10K pulled down all of the modules we specified in the **development** branch'es **Puppetfile**?  Pretty cool, eh?

Next let's copy our **development** `Puppetfile` in to the **production** branch, so that our **production** environment gets the modules as well.

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (development)$ git checkout production
Switched to branch 'production'
Your branch is up-to-date with 'origin/production'.
```

We switch to the **production** branch, getting ready to create/edit the Puppetfile in that branch...

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ git diff --stat development
 Puppetfile                            | 6 ------
 hieradata/common.yaml                 | 1 +
 hieradata/node/agent.example.com.yaml | 1 -
 3 files changed, 1 insertion(+), 7 deletions(-)
```

Notice that the development branch has 3 differeing files, one of which is the Puppetfile.
Remember, we've created a Puppetfile in the **development** branch, but not the **production** branch.
Let's simply checkout the development branch'es Puppetfile in to the **production** branch (which is our current branch) and edit it...

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git checkout development Puppetfile
```

Add it, commit and push it...

```
mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git add Puppetfile

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)*$ git commit -a -m 'initial commit'
[production 2230b9e] initial commit
 1 file changed, 6 insertions(+)
 create mode 100644 Puppetfile

mbp-mark:[/Users/bentlema/gitlab/puppet/control] (production)$ git push
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
   1ead2c1..2230b9e  production -> production
```

Now let's run R10K again, and see if we get everything...

```
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Environment development is now at cb26335eb5c41c808979a5e13f51b41715ceb4f7
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/motd
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/registry
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/master
INFO     -> Environment master is now at 3e6627e116e24bbdf7e4d24b24d67d4aa586634e
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Environment production is now at 2230b9ef9a1ef461ac9c336663891485649fd36c
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/motd
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/ntp
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/registry
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/stdlib
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/timezone
```

Looks good, all except for that **master** environment in there.  Since Git creates the **master** branch by default, and we dont need or want a **master** Puppet Environment, we should delete that branch from our Git repository.  If we dont, we'll end up with a **master** environment on our Puppet Master.  It wont hurt anything, but will be annoying.

Delete the **local master branch** with: `git branch -d master`

Delete the **remote master branch** with: `git push origin --delete master`

Try it now...

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git branch -a
  development
  master
* production
  remotes/origin/development
  remotes/origin/master
  remotes/origin/production
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git branch -d master
Deleted branch master (was 056f697).
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
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
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
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

The **master** branch is still configured as the **default** branch within
GitLab, but we've deleted it. To fix this, go into the Project Settings, and
change the default branch to **production**

- Settings --> Edit Project --> Default Branch --> Select 'production'

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Training/control] (production)$ git push origin --delete master
To ssh://localhost/puppet/control.git
 - [deleted]         master
```

Okay, re-run R10K again...

```
[root@puppet tmp]# r10k deploy environment -vp
INFO     -> Deploying environment /tmp/r10k-test/development
INFO     -> Environment development is now at cb26335eb5c41c808979a5e13f51b41715ceb4f7
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/motd
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/ntp
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/registry
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/stdlib
INFO     -> Deploying Puppetfile content /tmp/r10k-test/development/modules/timezone
INFO     -> Deploying environment /tmp/r10k-test/production
INFO     -> Environment production is now at 2230b9ef9a1ef461ac9c336663891485649fd36c
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/motd
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/ntp
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/registry
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/stdlib
INFO     -> Deploying Puppetfile content /tmp/r10k-test/production/modules/timezone
INFO     -> Removing unmanaged path /tmp/r10k-test/master
```

Notice that the un-used **master** directory environment was removed?  That's what we want.

### Put R10K in control

Finally!

Update the **r10k.yaml** so that **basedir** points to the real PE environments dir like this:

```
cd /etc/puppetlabs/r10k
vi r10k.yaml
```

Update the **basedir** as follows...

```yaml
---
cachedir: '/var/cache/r10k'

sources:
  puppet-training:
    remote:  'git@gitlab:puppet/control'
    basedir: '/etc/puppetlabs/code/environments'
```

Now, when we run r10k, it will completely wipe anything in the basedir, and then pull everything in exactly like we were doing into our test dir... Let's go ahead and do that...

```
[root@puppet r10k]# r10k deploy environment -vp --verbose debug
[2016-11-16 14:22:25 - DEBUG] Fetching 'git@gitlab:puppet/control' to determine current branches.
[2016-11-16 14:22:25 - INFO] Deploying environment /etc/puppetlabs/code/environments/development
[2016-11-16 14:22:25 - DEBUG] Replacing /etc/puppetlabs/code/environments/development and checking out development
[2016-11-16 14:22:25 - INFO] Environment development is now at cb26335eb5c41c808979a5e13f51b41715ceb4f7
[2016-11-16 14:22:25 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/development/modules/motd
[2016-11-16 14:22:25 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/development/modules/ntp
[2016-11-16 14:22:25 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/development/modules/registry
[2016-11-16 14:22:25 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/development/modules/stdlib
[2016-11-16 14:22:25 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/development/modules/timezone
[2016-11-16 14:22:25 - DEBUG] Purging unmanaged Puppetfile content for environment 'development'...
[2016-11-16 14:22:25 - INFO] Deploying environment /etc/puppetlabs/code/environments/production
[2016-11-16 14:22:25 - DEBUG] Replacing /etc/puppetlabs/code/environments/production and checking out production
[2016-11-16 14:22:26 - INFO] Environment production is now at 2230b9ef9a1ef461ac9c336663891485649fd36c
[2016-11-16 14:22:26 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/production/modules/motd
[2016-11-16 14:22:26 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/production/modules/ntp
[2016-11-16 14:22:26 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/production/modules/registry
[2016-11-16 14:22:26 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/production/modules/stdlib
[2016-11-16 14:22:26 - INFO] Deploying Puppetfile content /etc/puppetlabs/code/environments/production/modules/timezone
[2016-11-16 14:22:26 - DEBUG] Purging unmanaged Puppetfile content for environment 'production'...
[2016-11-16 14:22:26 - DEBUG] Purging unmanaged environments for deployment...
```

Now do a test puppet run on both the puppet master and the gitlab VM, and you should still get a clean run...

If you also have the **agent** VM up and running, you should get a clean run on it as well.

### Cleanup

Remember that we used the `share/` directory as a temporary staging directory.  Let's clean that up so Git doesn't bug us about untracked files there...

```
mbp-mark:[/Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share] (master)*$ pwd
/Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share
mbp-mark:[/Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share] (master)*$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

Untracked files:
  (use "git add <file>..." to include in what will be committed)

    development/
    production/

no changes added to commit (use "git add" and/or "git commit -a")


mbp-mark:[/Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share] (master)*$ rm -rf development production
mbp-mark:[/Users/bentlema/Documents/Git/GitHub/bentlema/puppet-tutorial-pe/share] (master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```

### R10K Notes

So we've configured R10K, but it's not going to magically run itself.

We previously talked about configuring the **postrun_command** in the **puppet.conf** to run our 
`r10k deploy environment` command every 30 minutes, and we could certainly do that, but something
more interesting would be to setup GitLab to trigger R10K automatically every time someone 
pushes to the control repo.

Let's look at how we can setup a post-receive hook...

### Git post-receive hook

Let's setup a **post-receive hook** which will ssh from GitLab to the puppet master and run r10k for us.
This way, every time we do a **git push** to GitLab, it will automatically run R10K on the master for us.

There's more than one way to do this, but a few that come to mind are:

1. setup the *git* account as an MCollective client, and use the r10k module to enable the 'mco r10k sync' command
2. setup ssh keys to allow the git user to run commands on the puppet master password-less
3. configure a webhook within GitLab to trigger an R10K run

In a production environment, you'd likely want to setup a [webhook](http://127.0.0.1:24080/help/web_hooks/web_hooks), but...

To keep things simple, let's just setup SSH keys.  Make sure you **trust** the GitLab server, as we will
be giving it the ability to ssh in as root on our puppet master! (Take care to understand the security
implications here.)

On the GitLab VM...

Become the **git** user this time (as we don't need to be root)

```
sudo su - git
```

```
[git@gitlab ~]# cd /var/opt/gitlab/git-data/repositories/puppet/control.git
[git@gitlab control.git]# mkdir custom_hooks
[git@gitlab control.git]# cd custom_hooks/
```

Make a bash script called **post-receive** ...

```
vi post-receive
```

...and copy-and-paste in this content:

```
#!/bin/bash

# List of Puppet Masters to update
pe_masters="
puppet"

PATH="/opt/gitlab/bin:/opt/gitlab/embedded/bin:/opt/gitlab/embedded/libexec/git-core:/opt/puppetlabs/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin"
export PATH

echo
echo "Running post-receive hook..."
for pm in $pe_masters ; do
  ssh -l root $pm "echo \"[$pm] Updating...\" ; /usr/local/bin/r10k deploy environment -p ; echo \"[$pm] Done.\""
done
echo

```

Make sure to give read/execute perms on the post-receive script

```
[git@gitlab custom_hooks]# chmod a+rx post-receive
```

All that does is iterate through a list of puppet masters, and ssh as root to each one and run r10k.
(We only have one puppet master in our training environment, but most production environments would have 2 or more for load-balancing.)

Make sure you are the git user (not root), and create an ssh key pair, and then copy the public key to the root user's ~/.ssh/authorized_keys on the puppet master...

```
-sh-4.2$ cd     # get back to git's home dir

-sh-4.2$ pwd
/var/opt/gitlab

-sh-4.2$ ls -al .ssh
total 8
drwx------  2 git  git    55 Mar  9 13:35 .
drwxr-xr-x 13 root root 4096 Mar  9 10:59 ..
-rw-------  1 git  git  1087 Mar  9 14:58 authorized_keys
-rw-r--r--  1 git  git     0 Mar  9 14:58 authorized_keys.lock

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

Add that public key to root's ~root/.ssh/authorized_keys file on the master using the ssh-copy-id command:

```
-sh-4.2$ ssh-copy-id -i .ssh/id_rsa.pub root@puppet
The authenticity of host 'puppet (192.168.198.10)' can't be established.
ECDSA key fingerprint is 1e:67:49:63:1f:80:8b:a4:19:16:1e:f8:b1:28:82:8d.
Are you sure you want to continue connecting (yes/no)? yes
/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@puppet's password: vagrant

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@puppet'"
and check to make sure that only the key(s) you wanted were added.
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

Those lines beginning with **"remote:"** are the actual output from your post-receive hook.  

There are several [other Git hooks](https://docs.gitlab.com/ce/administration/custom_hooks.html) you could configure as well, including pre-commit, post-commit, update, etc.

### Summary

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

### REMINDER - No more editing Puppet code directly on the Puppet Master

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


