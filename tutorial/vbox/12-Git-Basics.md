<-- Back to **Lab #11** - [Roles & Profiles](11-Roles-and-Profiles.md#lab-11)

---

### **Lab #12** - Git Basics

---

### Overview

First of all, Git is a huge topic.  It will be impossible to cover everything in this
quick overview, but we will cover all of what you'll need to work with Git to manage
change to your Puppet code.

What is Git?

Simply put, Git is a distributed version control system.  The book *[Pro Git](https://git-scm.com/book/en/v2)*
describes Git as a mini-filesystem with snapshot capabilities, and all of the Git commands you
utilize manipulate that mini-filesystems and its [stream of snapshots](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics#Snapshots,-Not-Differences).

Git is the tool that will...
- track changes to your code (audit trail)
- allow multiple code-maintainers to make changes simultaneously, and resolve conflicts
- allow multiple complete clones of a repo for disaster recovery

I highly recommend reading *[Pro Git](https://git-scm.com/book/en/v2)* when you get a chance.
It's certainly not required to work through these labs, but if you're the type of person
that can read a technical book and absorb the content for use later, it's a must read.  If
you're like me, and tend to learn more through examples, and then consult the book when you
want to learn more about a specific feature of Git, then use it as a reference.

### The Repository

A "Git Repo" is just a self-contained bundle of files along with its commit history.
As mentioned previously, this *commit history* is like a stream of snapshots.
Typically the files in a Git Repo are source code--in our case: Puppet Manifests.
However, a Git repo can contain any text and/or binary files.  Usually binary files
would be excluded from the repo, as you're probably not interested in versioning
them (e.g. they might be object files left from a compile/software build).  In any
case, Git is happy to store versions of any type of file you might want in your repo.

You can find many public Git repositories out on <https://github.com/explore> but
remember that the nice WebGUI is not the repo itself, it's just a nice view into the
repo.  GitHub is a Git server (or "Git Hosting Service) sitting in front of the
actual Git repo--actually thousands of Git repos.  There are other Git servers out
there too, where both public and private repos can be hosted, and access controled.
We are using one called GitLab for this training.

Some well known Git servers available are:
- [GitHub](http://github.com)
- [Atlassian BitBucket](https://bitbucket.org/)
- [GitLab](https://gitlab.com/explore)
- [Gitolite](http://gitolite.com/)
- [Gerrit Code Review](https://www.gerritcodereview.com)

Let's talk about the basics of Git...

### Git Clone

To make a complete copy of a remote repo, you can use *git clone*

- It makes an exact clone of the remote Git repository.
- Git will also setup a *remote* for pushing to and pulling from
- Git will also configure this remote as a tracking branch

The *remote* is just a meaningful name given to the remote URL which you can refer
to with other git commands.  Git will setup a remote with the name *origin* by default.

Type *git remote -v* to see the configured remote of your control repo.

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git remote -v
origin  ssh://localhost/puppet/control.git (fetch)
origin  ssh://localhost/puppet/control.git (push)
```

In our case, the remote with name *origin* refers to a repo accessible via
ssh on localhost.  Remember that we had previously setup our ~/.ssh/config
to know the correct ssh port and private key to use for localhost.

Git will also use *origin* as the default for other commands if you don't
specify a remote.

---

### Git Status

The *git status* command is useful for telling you what branch you're on, as
well as the status of the staging area.  When you make changes to files that
Git is tracking, it will notice that, and show you that it noticed.

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

nothing to commit, working directory clean
```

Notice that our *git status* output tells us that we are on the *production*
branch, and that it also believes we are up-to-date with the remote tracking
branch, referred to as *origin/production*.

As an example, let's edit our *environment.conf* and add a comment at the top
like this:

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ cat environment.conf
# site hosts local modules, while modules hosts R10K-managed modules
modulepath = site:modules:$basemodulepath
```

We've just made a change in *the working tree*

Now run *git status* again...

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

  modified:   environment.conf

no changes added to commit (use "git add" and/or "git commit -a")
```

Now it tells you it noticed that the *environment.conf* was modified in the
working tree.   However, it's still not added to the *staging area*

---

### The Staging Area (Index)

Git has something called a *Staging Area*.  It's where we can "stage" our changes
in preperation to permanently commit them to the repo.  Once you commit a
change, it's there forever in the commit history.

---

### Git Diff

To see what changes we've made in the working tree that are not yet staged,
use *git diff* or *git diff <filename>* for a specific file.   In our example,
if you do *git diff environment.conf* we'll see the comment we added with a
*plus* at the beginning of the line indicating that it was added.  If you're
on a ANSI color terminal, it will also be in *GREEN*.  Any lines removed would
be in *RED*.  Unchanged lines displayed for context, would just be in your
default terminal font color.

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git diff environment.conf
diff --git a/environment.conf b/environment.conf
index ec1ce4e..0de3371 100644
--- a/environment.conf
+++ b/environment.conf
@@ -1 +1,2 @@
+# site hosts local modules, while modules hosts R10K-managed modules
 modulepath = site:modules:$basemodulepath
```

---

### Git Add

To add a file to the staging area, use the *git add* command.  In our example,
we can simply run *git add environment.conf*

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  modified:   environment.conf

```

Also, notice now that if we run *git diff* we dont see any changes.  This is
because our changes in the working tree have been staged, so the working tree
matches what's in the staging area.

To see difference between the remote branch (origin/production) and the staging
area, you can run *git diff* like this:

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git diff origin/production environment.conf
diff --git a/environment.conf b/environment.conf
index ec1ce4e..0de3371 100644
--- a/environment.conf
+++ b/environment.conf
@@ -1 +1,2 @@
+# site hosts local modules, while modules hosts R10K-managed modules
 modulepath = site:modules:$basemodulepath
```

The *git diff* command can show you a diff of pretty much anything you want,
it's just a matter of knowing what you want to compare.

There are lots of things you could compare:

1. local working-tree
2. local staging area (also called the *index* in the git man pages)
3. local repo / same branch
4. local repo / different branc
5. remote repo / same branch
6. remote repo / different branch

We will go over all of these in a later lab...

---

### Git Commit

Now that we're run the *git add* on our file, and the *git status* shows that
it's staged (ready to be committed), we can go ahead and either:

1. commit the change
2. un-stage the change

Let's go ahead an commit the change. We will talk more about un-staging in a later lab...

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git commit -m 'added comment'
[production 8c229f1] added comment
 1 file changed, 1 insertion(+)
```

The *-m* option is short for *commit message* and is just a descriptive message
to go along with the commit in case we need to find it in the future, the message
should make it easier to identify later what changes were made

---

### Git Push

If we do a *git status* again, we'll see something new:

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is ahead of 'origin/production' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working directory clean
```

Notice that Git is telling us *Your branch is ahead of 'origin/production' by 1 commit.*

Isn't that nice of it?

Remember earlier we looked at *git clone* and mentioned that when we clone a
repo, Git will automatically setup the remote tracking branch.  Git is comparing
our repo's production branch with what it knows about the remote repo's production
branch, and it's noticing that we just made 1 new commit, but the remote doesn't
yet have that commit.  We need to *git push* it

Note:  Git only knows about the remote since the last time we did a *git fetch*
or *git pull*.  It's *NOT* actively going out a looking at the real remote repo
every time you do a *git status*.  It's just remembering from it's local copy
of the remote.

Let's push our change to the remote (in this case, our GitLab server)...

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 335 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   64f3df7..8c229f1  production -> production
```

...and do another *git status* ...

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

nothing to commit, working directory clean
```

---

### Git Pull

If you have multiple people working in the same repo, they will also have a
clone on their local workstation, and will also be making changes and
adding/committing/pushing up to the remote.  If you're both working on the
same files, it's possible you could have an outdated copy if the other person
had edited a file and pushed their change to the remote after you cloned it.
So how to we keep our *local* clone up-to-date with the *remote*?

A good habit to get into is to also do a *git pull* prior to doing any work
in your local clone of a repo.  This ensures you're pulling down any changes
other folks have made, and will potentially avoid merge conflicts in the future.

When you do a **git pull** Git will pull down changes to the current branch,
and bring your branch up-to-date with the remote.  It will do this by mergeing
in those changes automatically for you.  It is possible if you've changed
the same file as someone else, you could get a merge conflict, and have to
resolve that conflict, and then manually add and commit the changes.

Git can also be configured to fetch all changes in other branches as well.
Depending on the version of Git your using, this behavior may differ, so just
to be safe, it's also good to *git pull* after switching to a different branch.

---

### Git Branches

Although we've seen *branches* a little bit (e.g. *production branch*) we've
not really talked about what a branch is.  Git allows us to spin off a copy of
our repo, makes changes within that copy (called a branch), and then either
merge our changes up to the parent branch, or discard our changes.  This idea
becomes very useful when making changes to puppet code without affecting the
production environment, but still allowing us to test our code.

The easiest way to create a new branch is to use *git checkout -b <branch-name>*

It's a shortcut for creating a branch, and then checking out that branch.
The longer version would be a *git branch <branch-name>*
followed by *git checkout <branch-name>* but why type all of that?

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

nothing to commit, working directory clean

[/Users/Mark/Git/Puppet-Training/control] (production)$ git branch foo

[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

nothing to commit, working directory clean

[/Users/Mark/Git/Puppet-Training/control] (production)$ git branch
  development
  foo
* production

[/Users/Mark/Git/Puppet-Training/control] (production)$ git checkout foo
Switched to branch 'foo'

[/Users/Mark/Git/Puppet-Training/control] (foo)$ git branch
  development
* foo
  production
```

We've just created a new branch called **"foo"**, then checked it out to work on.

Notice that **checkout** is just another way of saying **switch to this branch**

Also, notice we've seen the new command **git branch** which shows us the branches
in the repo, and puts an asterisk next to the currently-checked-out branch.

---

### Git Merge

When we make changes in another branch, it's possible that we will eventually
want to merge those changes back in to the branch we split off of.

We branched off of *production* and want to make a change, test it, and then
merge it back in to *production*

Let's add a silly comment to our environment.conf again...

```
[/Users/Mark/Git/Puppet-Training/control] (foo)$ vi environment.conf

[/Users/Mark/Git/Puppet-Training/control] (foo)*$ cat environment.conf
# site hosts local modules, while modules hosts R10K-managed modules
modulepath = site:modules:$basemodulepath
# this is another wonderful comment at the end of the file
```

Let's add/commit that change...

```
/Users/Mark/Git/Puppet-Training/control] (foo)*$ git status
On branch foo
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

  modified:   environment.conf

no changes added to commit (use "git add" and/or "git commit -a")

[/Users/Mark/Git/Puppet-Training/control] (foo)*$ git commit -a -m 'a silly comment'
[foo eb20962] a silly comment
 1 file changed, 1 insertion(+)
```

Now let's look at the differences between our **production** branch and our **foo** branch

```
[/Users/Mark/Git/Puppet-Training/control] (foo)$ git diff production environment.conf
diff --git a/environment.conf b/environment.conf
index 0de3371..6c2bae3 100644
--- a/environment.conf
+++ b/environment.conf
@@ -1,2 +1,3 @@
 # site hosts local modules, while modules hosts R10K-managed modules
 modulepath = site:modules:$basemodulepath
+# this is another wonderful comment at the end of the file
```

You could also explicitely specify the two branches like this:

```
git diff production..foo environment.conf
```

...but if you don't explicitely specify the second branch, git will compare
the currently-checked-out branch with the one specified.

Now, to do a merge, we have to **checkout the branch we want to merge *in* to**
first, so **git checkout production**

```
[/Users/Mark/Git/Puppet-Training/control] (foo)$ git checkout production
Switched to branch 'production'
Your branch is up-to-date with 'origin/production'.

[/Users/Mark/Git/Puppet-Training/control] (production)$ git merge foo
Updating 8c229f1..eb20962
Fast-forward
 environment.conf | 1 +
 1 file changed, 1 insertion(+)

[/Users/Mark/Git/Puppet-Training/control] (production)$ cat environment.conf
# site hosts local modules, while modules hosts R10K-managed modules
modulepath = site:modules:$basemodulepath
# this is another wonderful comment at the end of the file

[/Users/Mark/Git/Puppet-Training/control] (production)$ git status
On branch production
Your branch is ahead of 'origin/production' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working directory clean
```

A few things happened there:

1. We checked out production
2. We merged foo in to production
3. Because the merge didn't encounter any conflicts, it was automatically committed
4. Notice our production branch is 1 commit behind origin/production

Now that we've merged foo back in to production, we likely want to update the
remote repo as well with a **git push**, but first, let's use **git diff** to compare
our local repo with the remote repo:

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git diff origin/production environment.conf
diff --git a/environment.conf b/environment.conf
index 0de3371..6c2bae3 100644
--- a/environment.conf
+++ b/environment.conf
@@ -1,2 +1,3 @@
 # site hosts local modules, while modules hosts R10K-managed modules
 modulepath = site:modules:$basemodulepath
+# this is another wonderful comment at the end of the file
```

Okay, let's go ahead an push our production branch to the remote...

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 6, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 339 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   8c229f1..eb20962  production -> production
```

---

### More about branches

Let's do a `git branch -a` to see all of our local and remote branches...

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git branch -a
  development
  foo
* production
  remotes/origin/development
  remotes/origin/production
```

Notice that even after we did a push, the *foo* branch is local only.  If we
want a remote tracking branch for *foo*, we could push it as well...

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ git checkout foo
Switched to branch 'foo'

[/Users/Mark/Git/Puppet-Training/control] (foo)$ git push
fatal: The current branch foo has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin foo

```

Isn't that nice of Git to tell us how to do things we likely want to do?

```
[/Users/Mark/Git/Puppet-Training/control] (foo)$ git push --set-upstream origin foo
Total 0 (delta 0), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
 * [new branch]      foo -> foo
Branch foo set up to track remote branch foo from origin.

[/Users/Mark/Git/Puppet-Training/control] (foo)$ git branch -a
  development
* foo
  production
  remotes/origin/development
  remotes/origin/foo
  remotes/origin/production

```

Cool, now we see a **remotes/origin/foo** in the list, which means our branch
exists on the remote called **origin** and our local branch is tracking it


---

### Another example...

We configured Hiera in an earlier lab, but one thing we left un-done was the
location of the **hiera.yaml**.  It's fine sitting where it's at, but it's
outside of Git control.  Wouldn't we like our **hiera.yaml** to be safely located
in our Git control repo along with the actual Hiera Data?  Let's move it...

The **hiera.yaml** is a pretty small YAML text file, so let's just copy-and-paste
to pull it off of our master, and get it in our Git repo..

On your master...

```
[root@puppet ~]# cat /etc/puppetlabs/puppet/hiera.yaml
---
:backends:
  - yaml

:hierarchy:
  - "node/%{::trusted.certname}"
  - "role/%{::role}"
  - "location/%{::location}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/code/environments/%{environment}/hieradata"

```

Now on your workstation where you are hosting your own clone of the control repo,
let's create the **hiera.yaml** at the **top-level** of your repo.  (It should
be at the same level as your **environment.conf**)

```
[/Users/Mark/Git/Puppet-Training/control] (production)$ echo '
---
:backends:
  - yaml

:hierarchy:
  - "node/%{::trusted.certname}"
  - "role/%{::role}"
  - "location/%{::location}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/code/environments/%{environment}/hieradata"
' >> hiera.yaml

```

Now cat your new hiera.yaml and make sure it looks correct (comparing it to
the one you just copied)...

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ cat hiera.yaml
---
:backends:
  - yaml

:hierarchy:
  - "node/%{::trusted.certname}"
  - "role/%{::role}"
  - "location/%{::location}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/code/environments/%{environment}/hieradata"

```

Okay, now let's add, commit, and push it...

```
[/Users/Mark/Git/Puppet-Training/control] (production)*$ git add hiera.yaml

[/Users/Mark/Git/Puppet-Training/control] (production)*$ git status
On branch production
Your branch is up-to-date with 'origin/production'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  new file:   hiera.yaml

[/Users/Mark/Git/Puppet-Training/control] (production)*$ git commit -m 'put under git control'
[production 522c89a] put under git control
 1 file changed, 15 insertions(+)
 create mode 100644 hiera.yaml

[/Users/Mark/Git/Puppet-Training/control] (production)$ git push
Counting objects: 5, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 444 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   708d37f..522c89a  production -> production

```

Next, we should move the original **hiera.yaml** off to the side, and then make a symlink to the new location.


```
[root@puppet ~]# cd /etc/puppetlabs/puppet

[root@puppet puppet]# ls -al hiera*
-rw-r--r-- 1 root root 198 Mar  2 15:43 hiera.yaml
-rw-r--r-- 1 root root 314 Mar  2 15:27 hiera.yaml.orig

[root@puppet puppet]# mv hiera.yaml hiera.yaml-2017-01-21

[root@puppet puppet]# ln -s environments/production/hiera.yaml

[root@puppet puppet]# ls -al hiera*
lrwxrwxrwx 1 root root  34 Mar 16 11:30 hiera.yaml -> environments/production/hiera.yaml
-rw-r--r-- 1 root root 198 Mar  2 15:43 hiera.yaml-2016-03-16
-rw-r--r-- 1 root root 314 Mar  2 15:27 hiera.yaml.orig

```

Note:  even though we've moved our **hiera.yaml** under Git control, gaining the ability
to track changes, don't forget that a restart of the puppet master is required in
order to re-read the file and "activate" the changes.


---

### Example 2:  Remember that we have a develpment branch?

We've largely been working with the **production** branch in our control repo, but
remember that we've created a **development** branch as well?

Back in Lab #11, we setup our code base to use the **Roles & Profiles Pattern**
but we only did this for the production branch.  Let's also get the development
branch setup properly.


```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (production)$ git branch -a
  development
  foo
* production
  remotes/origin/development
  remotes/origin/foo
  remotes/origin/production

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (production)$ git checkout development
Branch development set up to track remote branch development from origin.
Switched to a new branch 'development'

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git diff --stat production
 environment.conf                                         | 20 ++++++++++++++++++--
 hiera.yaml                                               | 13 -------------
 hieradata/common.yaml                                    |  5 ++---
 hieradata/node/agent.example.com.yaml                    |  1 +
 {site/profile/manifests => manifests}/common_hosts.pp    |  2 +-
 {site/profile/manifests => manifests}/common_packages.pp |  2 +-
 6 files changed, 23 insertions(+), 20 deletions(-)
```

Notice that there are a bunch of differences between **production** and **development** branches.

Let's try to merge the **production** changes in to the current branch, which is the **development** branch.

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git merge --no-commit production
Auto-merging site/profile/manifests/common_packages.pp
Auto-merging site/profile/manifests/common_hosts.pp
Auto-merging hieradata/common.yaml
CONFLICT (content): Merge conflict in hieradata/common.yaml
Automatic merge failed; fix conflicts and then commit the result.
```

Hmmm, we got a merge conflict with our common.yaml.  Let's look at that.

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git status
On branch development
Your branch is up-to-date with 'origin/development'.
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:

    modified:   environment.conf
    new file:   hiera.yaml
    renamed:    manifests/common_hosts.pp -> site/profile/manifests/common_hosts.pp
    renamed:    manifests/common_packages.pp -> site/profile/manifests/common_packages.pp

Unmerged paths:
  (use "git add <file>..." to mark resolution)

    both modified:   hieradata/common.yaml

```

Looks like our `common.yaml` has conflicts.  Since we know that the version
we have in the **production** branch is correct, let's just checkout that version.  If we
really wanted to, we could also just edit the file with conflicts, and make the desired
changes, git add them, commit, and push, and be done with it.

Follow along and see how we can resolve the conflict(s)...

Let's look at our `common.yaml` ...

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git diff hieradata/common.yaml
diff --cc hieradata/common.yaml
index 05bee3b,bc84197..0000000
--- a/hieradata/common.yaml
+++ b/hieradata/common.yaml
@@@ -1,8 -1,9 +1,14 @@@
  ---

  classes:
++<<<<<<< HEAD
 +   - common_hosts
 +   - common_packages
++=======
+    - profile::common_hosts
+    - profile::common_packages
+    - motd
++>>>>>>> production

  ntp::servers:
     - '0.pool.ntp.org'
```

Okay, we see that the conflict is in the common_hosts and common_packages classes.
We moved them, but hadn't updated the development branch.  Since we want what is
in production, let's simply checkout the production version, git add, commit, and push.


```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git checkout --theirs hieradata/common.yaml

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git status
On branch development
Your branch is up-to-date with 'origin/development'.
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:

    modified:   environment.conf
    new file:   hiera.yaml
    renamed:    manifests/common_hosts.pp -> site/profile/manifests/common_hosts.pp
    renamed:    manifests/common_packages.pp -> site/profile/manifests/common_packages.pp

Unmerged paths:
  (use "git add <file>..." to mark resolution)

    both modified:   hieradata/common.yaml
```

Okay, now add it and do a `git status` again...

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git add hieradata/common.yaml

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git status
On branch development
Your branch is up-to-date with 'origin/development'.
All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:

    modified:   environment.conf
    new file:   hiera.yaml
    modified:   hieradata/common.yaml
    renamed:    manifests/common_hosts.pp -> site/profile/manifests/common_hosts.pp
    renamed:    manifests/common_packages.pp -> site/profile/manifests/common_packages.pp
```

You fixed the conflict, and are ready to commit...

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)*$ git commit -m 'merge production in to development'
[development 9a8ba50] merge production in to development

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 346 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote:
remote: To create a merge request for development, visit:
remote:   http://gitlab.example.com/puppet/control/merge_requests/new?merge_request%5Bsource_branch%5D=development
remote:
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To ssh://localhost/puppet/control.git
   5053c6f..eee0234  development -> development
```

Let's compare the production and development environments on the master and see what we see...

```
[root@puppet ~]# cd /etc/puppetlabs/code/environments

[root@puppet environments]# (cd production && tree hieradata manifests site)
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

[root@puppet environments]# (cd development && tree hieradata manifests site)
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

Now let's see if we have any other differences between production and development:

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git diff --stat production
 hieradata/node/agent.example.com.yaml | 1 +
 1 file changed, 1 insertion(+)

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git diff production
diff --git a/hieradata/node/agent.example.com.yaml b/hieradata/node/agent.example.com.yaml
index 63453d9..7d07440 100644
--- a/hieradata/node/agent.example.com.yaml
+++ b/hieradata/node/agent.example.com.yaml
@@ -5,5 +5,6 @@ location: 'amsterdam'
 classes:
    - ntp
    - timezone
+   - motd

 timezone::timezone: 'US/Pacific'
```

We do have one difference.  We have the **motd** class in our `agent.example.com.yaml` in the development branch,
but not the production branch.  Since we already have the **motd** module declared in the `common.yaml` we dont
need it in the `agent.example.com.yaml`.

Rather than simply editing the `common.yaml`, let's do another merge, this time in the other direction.
Let's merge **production** <-- **development**.  Since I already know there will not be any conflicts,
I'm going to do the merge **without** the `--no-commit` option.  Doing the merge this way will immediately
commit the changes.

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (development)$ git checkout production
Switched to branch 'production'
Your branch is up-to-date with 'origin/production'.

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (production)$ git merge development
Updating 95d7b55..eee0234
Fast-forward
 hieradata/node/agent.example.com.yaml | 1 +
 1 file changed, 1 insertion(+)

mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (production)$ git push
Total 0 (delta 0), reused 0 (delta 0)
remote:
remote: Running post-receive hook...
remote: [puppet] Updating...
remote: [puppet] Done.
remote:
To git@localhost:puppet/control
   02c52fe..9a8ba50  production -> production
```

Notice that we always merge in to the current branch (the one we have checked out).  So if we
want to merge the differences in the **development** branch in to the **production** branch,
we ensure we have the **production** branch **checked out**, and then execute the merge
specifying the **"source"** branch.

Now, if you do another `git diff` you'll see that there are no more differences:

```
mbp-mark:[/Users/bentlema/Documents/Git/Puppet-Tutorial/control] (production)$ git diff --stat development
```

---

Continue on to **Lab 13** --> [Git Workflow](/tutorial/vbox/13-Git-Workflow.md)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

