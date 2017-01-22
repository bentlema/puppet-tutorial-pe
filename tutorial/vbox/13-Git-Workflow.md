<-- Back to **Lab #12** - [Git Basics](12-Git-Basics.md#lab-12)

---

### **Lab #13** - Git Workflow

### Under Construction

---

### Overview

We will work on a few things in this lab:

- Introduce a workflow for deploying puppet code to your puppet infrastructure
- More on Git branching and merging

### What the heck is a Workflow?

Well, it's just the order of tasks we perform to accomplish some work.  In our
case, the work is making changes to our puppet code to affect our infrastructure,
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


### Local and Remote Repositories

It is important to understand that your local clone of a repo is a full
complete copy of the repo, and identical to the remote repo as of the time
it was cloned.  However, the second your clone is created, it will diverge
from the remote as other developers push their changes up to the remote.

You do not automatically receive changes that are committed/pushed to the "upstream"
Git repo.  So commands like *git status* that tell you if you're ahead
or behind the remote tracking repo will probably only be useful if you're
truely up-to-date with the remote.

### Keeping Your Local Repo Up-to-date

To bring your local repository up-to-date with the remote, there are a few commands to know about:

- git fetch
- git pull

The *git fetch* command will fetch all objects and refs from a remote repository.

The *git pull* command will implicitely fetch, but will also merge in any new commits.

### STILL UNDER DEVELOPMENT ...


---

### Further Reading

http://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
http://stackoverflow.com/questions/2688251/what-is-the-difference-between-git-fetch-origin-and-git-remote-update-origin
http://stackoverflow.com/questions/1856499/differences-between-git-remote-update-and-fetch
http://stackoverflow.com/questions/17712468/what-is-the-difference-between-git-remote-update-git-fetch-and-git-pull

### Under Construction

Should cover the topic of creating *topic branches* for testing, or the use of a *long-lived personal dev branch*

Should cover how to DELETE a branch (Clean up after done working with a topic (aka "feature") branch


---

Continue on to Lab #14

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

