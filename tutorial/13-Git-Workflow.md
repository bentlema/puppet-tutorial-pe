
---

### Lab #13 - Git Workflow ###

---

## Overview ##

We will work on a few things in this lab:

- Introduce a workflow for deploying puppet code to your puppet infrastructure
- Setup post-receive hook to support our workflow
- Intermmediate-level Git topics (Branching, Merging, etc.)

## What the heck is a Workflow? ##

Well, it's just the order of tasks we perform to accomplish some work.  In our
case the work is making changes to our puppet code to affect our infrastructure,
while not breaking the production environment.

The high level description of a puppet workflow goes like this:

1.  Clone control repo, or if previously cloned, bring it up-to-date with remote
2.  Change dir to the repository to give Git a context to work
3.  Create new *feature branch* to commit your changes to
4.  Switch to your new feature branch
5.  Add or edit files to affect puppet
6.  Commit and Push your changes to the remote
7.  The push will trigger R10K run to build your environments, including a new environment named after your feature branch
8.  Login to a canary system, or system dedicated to testing puppet, and do a test puppet run on that host only to test your code
9.  Repeat from step 5 above until you're satisfied with your code
10. Switch to production branch, and merge in your feature branch


## Local and Remote Repositories ##

It is important to understand that your local clone of a repo is a full
complete copy of the repo, and identical to the remote repo as of the time
it was cloned.  However, the second your clone is created, it will diverge
from the remote as other developers push their changes up to the remote.

You do not automatically receive changes that are committed to the "upstream"
tracking repo.  So commands like *git status* that tell you if you're ahead
or behind the remote tracking repo will probably only be useful if you're
truely up-to-date with the remote.

## Keeping Your Local Repo Up-to-date ##

To bring your local repository up-to-date with the remote, there are a few commands to know about:

- git fetch
- git pull

The *git fetch* command will fetch all objects and refs from a remote repository.

The *git pull* command will implicitely fetch, but will also merge in any new commits.




http://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
http://stackoverflow.com/questions/2688251/what-is-the-difference-between-git-fetch-origin-and-git-remote-update-origin
http://stackoverflow.com/questions/1856499/differences-between-git-remote-update-and-fetch
http://stackoverflow.com/questions/17712468/what-is-the-difference-between-git-remote-update-git-fetch-and-git-pull


Should cover the topic of creating *topic branches* for testing, or the use of a *long-lived personal dev branch*

Should cover how to DELETE a branch (Clean up after done working with a topic (aka "feature") branch









## Git post-receive hook ##

Let's setup a post-receive hook which will ssh to the puppet master and run r10k for us.

There's more than one way to do this:

1. setup the *git* account as an MCollective client, and use the r10k module to enable the 'mco r10k sync' command
2. setup ssh keys to allow the git user to run commands on the puppet master password-less
3. configure webhook (don't know how, and wont take the time right now)
4. other

We will setup SSH keys.  Make sure you trust the GitLab server, as we will be giving it the ability to ssh in as root on our puppet master!



```
root@gitlab ~]# cd /var/opt/gitlab/git-data/repositories/puppet/control.git
[root@gitlab control.git]# mkdir custom_hooks
[root@gitlab control.git]# cd custom_hooks/
```

Make a bash script called *post-receive* with this content:

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
-sh-4.2$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/var/opt/gitlab/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
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

Add that public key to root's authorized_keys file on the master

Now test sshing from the git@gitlab account to root@puppet ...

```
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




