


Terms

Puppet Master
   - Certificate Authority (CA)
   - Master of Masters (MoM) - manages the other Puppet Infra nodes configuration (Compile masters, PuppetDB, PE Console, ActiveMQ hub/spokes)
   - Compile Master - another Puppet master that Agents point directly at

Puppet Agent
   - Every node out there gets an agent.  Even the masters run the puppet agent, and that's how they too get configured.


Puppet Terminology:

    Type
    Provider
    Resources
    Class
    Manifest
    Template
    Fact
    Hiera
    Roles & Profiles (are just classes organized in a meaningful way)
    Environment

Key config items configured in the puppet.conf

    server - the puppet master server to point at (typically one of the compile masters)
    environment - often correspond to 'Application Tiers' such as "Dev, Stage, Prod"
    certname - usually the same as the hosts FQDN, but can me anything you want.

Key key key thing about Roles and Profiles:

    Role is a Module
    Profile is a Module
    You should be able to classify a node with a SINGLE role and THAT’S IT. This makes
    node  classification simple and static:
        - the node gets its role
        - the role includes profiles
        - profiles call out to Hiera for data
        - that data is passed to component modules


Git Terminology:

    Git Repository / "Repo" - a directory that Git knows about changes in / tracks changes in
    Git Server - a server setup to host Git repositories
    Branch - Each repo can have any number of forks off of the master branch, and they are called 'branches'
    Commit - a snapshot of differences relative to the previous commits
    Local vs Remote Repositories
    Push - push commits to a remote repository
    Pull - fetch and merge remote changes into your local repository
    Merge - merge differences in one branch to another

How doe we use Puppet and Git together?

    R10K
    Puppetfile

How does a node (AKA host) know what puppet master to talk to?

How is the certname configured?

Talk about the /etc/puppetlabs/puppet/puppet.conf
   [main]
   [master]
   [agent]


What happens during a puppet run?

    - Send Facts to puppetmaster (they get instantiated as top-scope puppet variables)
    - Start building the client config catalog starting with the site.pp manifest
    - Within the site.pp there can be:
         Other static top-scope variables set (Note: any variable defined within the site.pp is automatically "Top Scope")
         Conditional statements and resource declarations that affect every node
         Hiera function calls
         Class declarations with class parameters that affect every node
         Include statements that affect every node
         Node definitions that can contain puppet code that only affects a specific node or sub-set of notes
            (Note: there is a special node 'default' definition that applies to any node that doesn't have its own node definition.)



Troubleshooting:

    - Verify the certname in puppet.conf matches the name of the node yaml file
    - If hostname is wrong and you fix it, you must also update the 'certname' in the puppet.conf, and re-gen and re-sign the client cert
    - Are you using the correct Puppetfile?
    - Verify your files (The ones you think you've added or changed) got pushed to the puppetmasters, and to the correct environment
    - For PE3.8 you may want to run the update-all-masters.sh script, or make sure to do your 'git push' on puppet-site-temp last
    - Use MCollective to ensure the classes are getting applied to your host
    - Trace through from node.yaml --> role.yaml --> classes (sometimes both the node and role yaml files will have classes)


Great Series on Roles, Profiles, and Puppet Workflow:

Building a Functional Puppet Workflow Part 1: Module Structure
http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-1/

Building a Functional Puppet Workflow Part 2: Roles and Profiles
http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/

Building a Functional Puppet Workflow Part 3: Dynamic Environments With R10k
http://garylarizza.com/blog/2014/02/18/puppet-workflow-part-3/

Building a Functional Puppet Workflow Part 3b: More R10k Madness
http://garylarizza.com/blog/2014/03/07/puppet-workflow-part-3b/

On R10k and 'Environments'
http://garylarizza.com/blog/2014/03/26/random-r10k-workflow-ideas/

R10k + Directory Environments
http://garylarizza.com/blog/2014/08/31/r10k-plus-directory-environments/

On Dependencies and Order
http://garylarizza.com/blog/2014/10/19/on-dependencies-and-order/

Workflows Evolved: Even Besterer Practices
http://garylarizza.com/blog/2015/11/16/workflows-evolved-even-besterer-practices/



Foreman

Even though PE includes the PE Console for node classification, it would be cool to configure The Foreman as an ENC just to show how an ENC can be tied in.

http://theforeman.org/manuals/1.5/index.html#3.5.5FactsandtheENC

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

