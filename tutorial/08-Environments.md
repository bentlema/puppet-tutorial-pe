
Puppet + Git Training
=====================

Lab #7 - Environments
=====================


### Overview ###

Time to complete:  ?? minutes

### Puppet Environments ###

Something that needs to be discussed before we move forward is the idea of
"Puppet Environments".  Understanding environments and how puppet uses them
will become very important when we start to talk about R10K and Git in the
coming labs.

So what exactly is a Puppet Environment?

PuppetLabs says this about environments:

>    A Puppet environment is an isolated set of Puppet manifests, modules, and data.
>
>    When a Puppet agent checks into a master and requests a catalog, it requests
>    that catalog from a specific environment.
>
>    Environments allow you to easily run different versions of Puppet code, so you
>    can test changes to that code without affecting all of your systems.

A Puppet Environment is just a container for puppet code.  You can have multiple code trees
for different sets of nodes.  Say you want all nodes "Type A" to use "Code Tree A" and all
nodes of "Type B" to use "Code Tree B", you can do that with Puppet environments.

Imagine you are supporting two different customers with the same PE infrastructure, and
want to keep the code separate.

Or, imagine you want to create a temporary test environment to test some code prior to
promoting it up to the production environment.  This is a very common use case, as we'll
see...

You will find a very useful way to envoke puppet from the command line is to
use the double-dash-environment option.  For example:

```shell
   puppet agent -t --environment=testing --noop
```

Even if the puppet.conf has `environment=production` in it, you can override that by specifying
an alternate environment from the command line.  This is very useful if you have some test boxes
that you want to test some new code on.  In the above example we ran puppet against a 'testing'
environment, and also specified '--noop' to ensure no changes are made to the host.  This way we can
see if the catalog compiles successfully, and if puppet wanted to make the changes desired.

We're also going to introduce a new piece of software called "R10K" (pronounced "Ar Ten Kay").
R10K will be coverd in a later lab along with configuring a Git repository for our code.  For now,
just know what R10K does:  it simply pulls code from any number of Git repos, and drops it in
the correct location on your puppet master(s).  One useful feature of R10K is that it maps every
branch in the Git repo to a puppet environment.  So, if you have a 'production' branch in your
Git repo, you will end up with a 'production' environment on your puppet master.  It's that simple.

Again, we will cover Git + R10K in a later lab.  I only introduce them breifly here so that we can
have the following discussion about **"Puppet Environments"**.  Going forward, I will simply write
**environment** when talking about Puppet Environments, as it gets old typing out Puppet Environemnts
over and over.

We learned a little bit about environments and the environment/ directory structure in
[Lab #4](/share/04-Puppet-Config-and-Code.md), but we didn't talk about
when and why we'd use one.

There are a few different ways to use environments, and I don't have a big enough sample to say
which way is more common or more "industry standard".  The following two use cases are
what I've seen out in the wild, with one of them being an install by PuppetLabs.

What I would call "The Basic Use Case" ...

  - All nodes are apart of the 'production' environment (every puppet.conf would have "environment = production")
  - New test environments are created by R10K dynamically, each environemnt corresponding to a Git branch
  - These test environments are used to test code changes on a test node (could be a non-critical prod node, or a dedicated test node)
  - The tested code (that passed) would then be merged in to the production branch, and end up in the production environment via an R10K pull
  - At this point the new/changed code would be live in the production environment, and applied to all puppet-managed nodes
  - Delete the test branch in Git (this branch is called a "feature branch")
  - Next time R10K runs, it would remove that test environemnt from the code tree on the master

So in the above use case, we have one "static" environment called "production".
All other puppet environments would be created dynamically by R10K, and be
short lived (just for testing code changes/additions to be introduced)

What I would call "The Multi-Customer Use Case" ...

If your company has one team that supports multiple customers, you might very
well have one environemnt per customer.  The workflow would be identical to
the above "Basic Use Case" except you would have multiple production environments,
one for each customer.  The group that maintains the puppet infrastructure,
doesn't necessarily have to own the code in each of these environments either.

  1. internal_customer_A
  2. internal_customer_B
  3. internal_customer_C
  4. etc.

The internal customers might be different groups, or different divisions within
the same company.  All of these environments would still be "production"
environments.  They might be named something like:

  1. customer_A_prod
  2. customer_B_prod
  3. customer_C_prod
  4. etc.

Having separate environemnts like this, and using R10K, gives the ability to
have different groups maintain the code for each environemnt.  Depending on
the Git server you use, and the access controls available, you could even
restrict one environemnt to certain individuals (perhaps ones that signed
an NDA) within a group, and restrict a different environemnt to different
individuals within the same team.  Once we cover Git + R10K in more depth,
this will all start to make sense.

The above 2 use cases for environemnts are what I've seen used at the
companies I've worked at.

There is the potential for some confusion when deciding how to build a new
puppet infrastructure for your company.  Every company is going to have
some vocabulary that is used around the shop regularly, and folks are
going to have an understanding of certain words that might only make
sense at that company.  One such word is "environment".

One company might use names like "Lab Environment" or "Prod Environment",
etc., while another company might refer to their "Private Cloud Environment",
or "Hybrid Cloud Environemnt", etc.  It's very common for a Dev Shop to
have "environments" like:

  1. Development
  2. Integration
  3. Staging
  4. Production

...but are they really environments?  Maybe.  Do they correspond to different
sets of servers?  Or are they simply different branches in a Git repo?  You
have to remember, what are we using Puppet to manage?  Sets of servers. Do
these "Development Environments" match up to different sets of servers with
different config for each?  Probably not entirely.  You might see some
integration servers that QA/Test folks run their test on.  You might see
some staging servers where UAT is done.  But the important thing to keep in
mind is what servers/nodes you're managing, and how the configuration will
be different for each set.

Example:  A SaaS company that is releasing a Web/Java app every month
may have their Integration, Staging, and Production servers.  All of
these servers are identical with the exception of the users that are
allowed to login to them.  Do you need to create entirely separate
environments just to deal with authentication?  Probably not.

Do you need to be able to upgrade a puppet module and test it first
in the integration and/or staging environments first, before promoting
to production?

You really have to attack this issue from the perspective of what data
you want to manage, and what your workflow will be.  It's not a simple
answer.  It's probably the most difficult question to answer when you're
in the position of designing your Puppet infrastructure from scratch.

What I'd suggest is keep it simple, and then modify your puppet code
as needed to acomodate a new use case.  Do your best to predict how
you need Puppet to support your existing infrastructure, but keep in
mind there's more than one way to do things. (E.g. use a custom Hiera
data key to assign an application tier, division, workgroup, etc.,
and make decisions in your profile code based on that, rather than
abusing the puppet environments feature.)

From my own experience, I prefer the "Basic Use Case" I outlined above.
I've used it at multiple companies, and it works well.  I would advise
against using "static environments" that matches your development code
flow (Dev, Int, Stg, Prod).  As you'll see later on, having long-lived
branches in Git will cause you Merge Agnst. E.g. "The Puppetfile problem."
I'm getting a little bit ahead of things, but trust me.  You will have
something called a Puppetfile, and you may want different version of
the Puppetfile in Dev, Stg, Prod, and you'll want to merge Dev into
Stg, and Stg into Prod, and you will not like it.

---

Continue on to **Lab #8** --> [Install GitLab](08-Install-GitLab.md)

---

### More Reading ###

Gary Larizza did a nice write-up on this issue here:  <http://garylarizza.com/blog/2014/03/26/random-r10k-workflow-ideas/>

Gary Larizza Video Presentation:  <https://puppetlabs.com/webinars/git-workflow-best-practices-deploying-r10k>

Here's a PuppetLabs write-up, though a bit outdated (pre-R10K), there are a lot of interesting comments at the end:   <https://puppetlabs.com/blog/git-workflow-and-puppet-environments>

Here's the PuppetLabs write-up including R10K in the workflow:  <https://puppetlabs.com/blog/git-workflows-puppet-and-r10k>

---

