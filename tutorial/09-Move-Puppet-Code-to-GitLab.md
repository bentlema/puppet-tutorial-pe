### Let's Setup root SSH access to GitLab ###

Puppet runs as root, and Puppet runs the r10k command to clone Git repos and pull them down to the master.  Knowing this, let's setup the root user to be able to interact with GitLab's puppet/control repo which we setup in the previous lab.

First, as root on your **puppet** vm, generate a new passphraseless keypair as follows:

```
[root@puppet ~]# ssh-keygen -t rsa -b 2048 -C 'root@puppet - Used by R10K to pull from GitLab'
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
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

Next, go to your puppet/control project, and click 'Settings' in the left sidebar
Then click on 'Deploy Keys'
Click 'New Deploy Key'
Put a meaningful title like 'Used by R10K to pull from GitLab'
Cut and paste in the public key you just generated
Then save it with 'Create New Deploy Key'

### Test that the root user can clone the puppet/control repo ###

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

### Create new branch called 'production' ###

In the GitLab webGUI, create a new branch called 'production'

### Test that R10K can pull down your code ###

Create an `/etc/puppetlabs/r10k/r10k.yaml` containing the following:

```yaml
---
cachedir: '/var/cache/r10k'

sources:
  puppet-training:
    remote:  'git@gitlab:puppet/control'
    basedir: '/tmp/r10k-test'
```

**WARNING**: Make sure that before you save this file that the **basedir** is set to a temporary location, and not the default.  If you leave the default as in the example r10k.yaml.example, you will blow away all of your existing code.  Bad!


```
[root@puppet ~]# cd /tmp
[root@puppet tmp]# r10k deploy environment -vp
INFO   -> Deploying environment /tmp/r10k-test/master
INFO   -> Deploying environment /tmp/r10k-test/production
```

Cool.  So we successfully tested that r10k runs using our test r10k.yaml file will work


### Let's Move Our Existing Puppet Code In To GitLab ###

How do we get our existing puppet code in to GitLab?

We've given the root user the ability to clone/pull code, but it can not push code (we're using a Deploy Key, which gives read-only access)

Should we temporarily give root access to push to the repo?  That's one option,
but since we've already cloned the repo to our workstation, and tested pushing
back and know it works, let's simply copy the files we need from the puppet
master to our local clone of the repo.

First, set the root password to something you know on your **puppet** VM, as we are going to scp files out of that VM to our workstation and sshd will prompt for the password.  Since this is a one-time thing, we're not going to setup ssh keys.

After you've set the root password, let's check our how Vagrant has configure ssh for our **puppet* vm, and then test SSH'ing in to it...

```
MBP-MARK:[/Users/Mark/Vagrant/puppet-training] (master)*$ vagrant ssh-config puppet
Host puppet
  HostName 127.0.0.1
  User vagrant
  Port 22022
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/Mark/Vagrant/puppet-training/.vagrant/machines/puppet/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Notice that Vagrant is using port 22022 as the forwarded port on our workstation, so we should be able to SSH in to that port, and land in our puppet VM...

```
MBP-MARK:[/Users/Mark/Vagrant/puppet-training] (master)*$ ssh -l root -p 22022 localhost
The authenticity of host '[localhost]:22022 ([127.0.0.1]:22022)' can't be established.
RSA key fingerprint is 25:cb:6c:9c:da:4e:6f:46:72:75:46:ac:18:19:31:ee.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:22022' (RSA) to the list of known hosts.
root@localhost's password:
Last login: Wed Mar  9 11:28:20 2016
[root@puppet ~]#
[root@puppet ~]#
[root@puppet ~]# exit
logout
Connection to localhost closed.
```

Great, it's working!

Next, change dir to the location of where you previously clone the puppet/control repo...

```
MBP-MARK:[/Users/Mark/Vagrant/puppet-training] (master)*$ cd
MBP-MARK:[/Users/Mark] $ cd Git/Puppet-Training/control/
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (master)$ ls -al
total 8
drwxr-xr-x   4 Mark  staff  136 Mar  9 13:41 .
drwxr-xr-x   3 Mark  staff  102 Mar  9 13:40 ..
drwxr-xr-x  15 Mark  staff  510 Mar  9 15:38 .git
-rw-r--r--   1 Mark  staff   14 Mar  9 13:41 README.md
```

We need to switch our branch over to the **production** branch, so when we copy the files over they land there instead of the **master** branch (which we will delete later)

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (master)$ git checkout production
Branch production set up to track remote branch production from origin.
Switched to a new branch 'production'
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$
```

Now, let's copy our manifests and hiera data here.  Don't copy the modules directory, as we will configure R10K to pull those down and install them.

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ scp -r -P 22022 root@localhost:/etc/puppetlabs/puppet/environments/production/manifests .
root@localhost's password:
common_hosts.pp                                                                                                                                                                                                                               100%  567     0.6KB/s   00:00
common_packages.pp                                                                                                                                                                                                                            100%  296     0.3KB/s   00:00
site.pp                                                                                                                                                                                                                                       100% 1655     1.6KB/s   00:00

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ scp -r -P 22022 root@localhost:/etc/puppetlabs/puppet/environments/production/data .
root@localhost's password:
agent.example.com.yaml                                                                                                                                                                                                                        100%   92     0.1KB/s   00:00
puppet.example.com.yaml                                                                                                                                                                                                                       100%   91     0.1KB/s   00:00
gitlab.example.com.yaml                                                                                                                                                                                                                       100%   92     0.1KB/s   00:00
woodinville.yaml                                                                                                                                                                                                                              100%  116     0.1KB/s   00:00
seattle.yaml                                                                                                                                                                                                                                  100%  116     0.1KB/s   00:00
amsterdam.yaml                                                                                                                                                                                                                                100%  116     0.1KB/s   00:00
common.yaml
```

Not a whole lot there, is there?  Now let's add/commit those files, and push up to GitLab...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)

  data/
  manifests/

nothing added to commit but untracked files present (use "git add" to track)
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git add data
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git add manifests
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  new file:   data/common.yaml
  new file:   data/location/amsterdam.yaml
  new file:   data/location/seattle.yaml
  new file:   data/location/woodinville.yaml
  new file:   data/node/agent.example.com.yaml
  new file:   data/node/gitlab.example.com.yaml
  new file:   data/node/puppet.example.com.yaml
  new file:   manifests/common_hosts.pp
  new file:   manifests/common_packages.pp
  new file:   manifests/site.pp

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git commit -m 'Initial commit'
[production 5c38df0] Initial commit
 10 files changed, 165 insertions(+)
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
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 15, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (14/14), done.
Writing objects: 100% (14/14), 2.17 KiB | 0 bytes/s, done.
Total 14 (delta 0), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   276c800..5c38df0  production -> production

```

Let's do another R10K test run from /tmp ...

```
[root@puppet tmp]# r10k deploy environment -vp
INFO   -> Deploying environment /tmp/r10k-test/master
INFO   -> Deploying environment /tmp/r10k-test/production

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
└── README.md

4 directories, 11 files
```

See how R10K pulled down our code and dropped it in /tmp/r10k-test as per our r10k.yaml ?

We need to do one more thing before we can swing it over to the final location of /etc/puppetlabs/puppet/environments

We need to get the **modules/** directory populated the same was as on the master currently

Look at what's in the production environment modules directory right now:

```
[root@puppet tmp]# cd /etc/puppetlabs/puppet/environments/production/
[root@puppet production]# tree -L 1 modules
modules
├── ntp
├── stdlib
└── timezone

3 directories, 0 files
```

There's 3 modules in there.  Before we tell R10K to pull code in to /etc/puppetlabs/puppet/environments we need to make sure the modules are pulled down, otherwise our puppet runs will break.

There's another feature of R10K that allows us to specify other Git repositories to pull modules from.  To control this, we create a config file called a **Puppetfile**.

Back on your workstation in your puppet/control repo, create a Puppetfile at the top level

Put these 2 lines in your Puppetfile

```
moduledir 'modules'
mod 'puppetlabs/stdlib', '4.11.0'
```

Then push to GitLab...

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ vi Puppetfile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git add Puppetfile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)*$ git commit -m 'Initial Puppetfile'
[production 96e2430] Initial Puppetfile
 1 file changed, 6 insertions(+)
 create mode 100644 Puppetfile
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 4, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 472 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
   5c38df0..96e2430  production -> production
```


And re-run r10k from your puppet master...

```
[root@puppet tmp]# r10k deploy environment -vp
INFO   -> Deploying environment /tmp/r10k-test/master
INFO   -> Deploying environment /tmp/r10k-test/production
INFO   -> Deploying module /tmp/r10k-test/production/modules/stdlib
```

Notice how R10K pulled down the stdlib now?  Pretty cool, eh?

Look at all those additional files in there now... (I've cut out part of the list here, but notice in the full output of the tree command there are 29 directories and 408 files.)

```
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
│   └── stdlib
│       ├── CHANGELOG.md
│       ├── checksums.json
│       ├── CONTRIBUTING.md
│       ├── examples
│       ├── lib
│       │   ├── facter
│       │   │   ├── facter_dot_d.rb
│       │   │   ├── package_provider.rb
│       │   │   ├── pe_version.rb
│       │   │   ├── puppet_vardir.rb
│       │   │   ├── root_home.rb
│       │   │   ├── service_provider.rb
│       │   └── puppet
│       │       ├── functions
│       │       ├── provider
│       │       └── type
│       ├── LICENSE
│       ├── manifests
│       │   ├── init.pp
│       │   └── stages.pp
│       ├── metadata.json
│       └── spec
[SNIP]
├── Puppetfile
└── README.md

39 directories, 408 files

```

Let's also add the ntp and timezone modules to our Puppetfile...Update your **Puppetfile** as follows, and then commit and push to GitLab, and re-run r10k again...

```
moduledir 'modules'
mod 'puppetlabs/stdlib', '4.11.0'
mod 'puppetlabs/ntp',    '4.1.2'
mod 'saz/timezone',      '3.3.0'
```

When you re-run r10k, you should see that it pulled down the ntp and timezone modules as well...

```
[root@puppet ~]# r10k deploy environment -vp
INFO   -> Deploying environment /tmp/r10k-test/master
INFO   -> Deploying environment /tmp/r10k-test/production
INFO   -> Deploying module /tmp/r10k-test/production/modules/stdlib
INFO   -> Deploying module /tmp/r10k-test/production/modules/ntp
INFO   -> Deploying module /tmp/r10k-test/production/modules/timezone
```

Notice that our **/tmp/r10k-test** directory has the exact same number of
files and directories as our live **/etc/puppetlabs/puppet/environments/production/modules/** directory.
This is a good indication that we've duplicated everything in our GitLab correctly.

```
[root@puppet ~]# find /tmp/r10k-test/production/modules/ | wc -l
516

[root@puppet ~]# find /etc/puppetlabs/puppet/environments/production/modules/ | wc -l
516
```

Match.

```
[root@puppet ~]# tree /tmp/r10k-test/production/modules | wc -l
518

[root@puppet ~]# tree /etc/puppetlabs/puppet/environments/production/modules/ | wc -l
518
```

Match.

```
[root@puppet ~]# tree /tmp/r10k-test/production/modules | grep directories
57 directories, 458 files

[root@puppet ~]# tree /etc/puppetlabs/puppet/environments/production/modules/ | grep directories
57 directories, 458 files
```

Match.

### Put R10K in control ###

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
[root@puppet r10k]# r10k deploy environment -vp
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/master
INFO   -> Deploying environment /etc/puppetlabs/puppet/environments/production
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/stdlib
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/ntp
INFO   -> Deploying module /etc/puppetlabs/puppet/environments/production/modules/timezone
```

Now do a test puppet run on both the puppet master and the gitlab VM, and you should still get a clean run...

### Summary ###

So what have we just done?

1. Created SSH key for the root user
  - Puppet runs as root, so this key will be used by puppet to pull from GitLab
2. Installed SSH key as **Deploy Key** in GitLab for puppet/control
  - This allows the root user to clone/pull that repo
3. Created a new branch called **production** in our control repo
4. Moved our existing Puppet code and Hiera data in to GitLab
5. Configured R10K to pull our Puppet code and Hiera data down to the Puppet Master
  - This includes configuring the **Puppetfile** to download the modules we use

From this point going forward we will **NOT** edit any code files directly on the Puppet Master.
Instead, we will edit our code and Hiera data on our workstation in our puppet/control repo.

In the next section we will look at Git in more detail, but the basic process going forward will be:
1.  Edit file in your local clone of the puppet/control repo
2.  Add/Commit new or changed file
3.  Push to the remote puppet/control repo hosted in/on GitLab
4.  Run R10K on the master to pull the code down (we will look at automating this later)

## Reminder ##

I didn't document how to delete the **master** branch... still need to do that, but dont feel like it right now...



---

---


