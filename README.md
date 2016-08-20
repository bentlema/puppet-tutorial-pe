# Start Here #

This is a **Puppet Enterprise** and **Git** training tutorial.
We will also use **Vagrant** and/or **Docker** to provision our training environment.

In this tutorial you will learn:

* How to Install Puppet Enterprise v3.8
* How to Configure Puppet Enterprise to use Hiera for Node Classification
* How to Use a Git Hosting server such as GitLab to host your Puppet Code
* Basic Puppet Coding
* Basic Git usage
* Basic Vagrant and/or Docker usage

### How to use this repo? ###

* Download and install Git client on your workstation ( https://git-scm.com/downloads )

* Clone this repo

     `git clone https://github.com/bentlema/puppet-training`

* Change directory to...

     `cd puppet-training`

* Begin following the Labs (links below)

### Navigating This Tutorial ###

This entire tutorial is of course a Git repository!  All of the tutorial
files are written in [Markdown](https://en.wikipedia.org/wiki/Markdown).
Make sure you're comfortable navigating this code repo before you start.
At any time, if you wish to return to this main README.md file, you can
click the bentlema/[puppet-training](https://github.com/bentlema/puppet-training#start-here) link at the top of the page.

### Minimum Requirements ##

* You will need the ability to install software on your workstation (Admin / Super-User privileges).
    - Git
    - VirtualBox
    - Vagrant or Docker

* Disk space:
    - 2GB of free disk space to acomodate software and VM/Container images

* Memory:
    - 8GB of RAM if using Docker Containers
    - 12GB of RAM if using VirtualBox VMs

* Note: You will use either Vagrant to spin up VM's or Docker to spin up Containers
    - We will not use both, so choose one, and you're good to go
    - Although Vagrant is capable of spinning up Docker containers, we will
      not use this capability

### Training Overview ###

What will we do in this training?

* Use Vagrant + VirtualBox (or Docker) to deploy your own training environment
* Install Puppet Enterprise (Monolithic Install), GitLab, and one additional training VM
* Learn the basics of Puppet Enterprise (Config, CLI, Environments, Code, etc.)
* Learn how to use Hiera for...
    - Node classification
    - Auto-lookup of class parameters
    - Hierarchical data lookup
* Learn how to install and Setup GitLab, and how to use it to host your Puppet code
* Learn how to setup R10K to automate code deployment


We will work through some Labs/Tutorials to get hands-on experience...


### Labs / Tutorials ###

Choose one of the following paths to setup your training environment (NOT Both):

* **Lab 01-V** - [Vagrant to deploy 3 training VMs](/tutorial/01v-Provision-Training-VMs.md)
* **Lab 01-C** - [Docker to deploy 3 training Containers](/tutorial/01c-Provision-Training-Containers.md)

Then choose one of the following to make sure your training environment is all
up and running and ready to start taking software.  If you're continuing straight
away from Lab #1, you should already be good to go.  If you're coming back to this
tutorial after a break, these will help you get your training environment started
back up, and walk you through any other preparation steps.

* **Lab 02-V** - [Prepare to Install Puppet Enterprise on VMs](/tutorial/02v-Prep-to-Install-Puppet-Master.md)
* **Lab 02-C** - [Prepare to Install Puppet Enterprise on Containers](/tutorial/02c-Prep-to-Install-Puppet-Master.md)

Once your training environment is setup, and you're comfortable with
either Vagrant+Virtualbox of Docker, continue with the remaining labs...

 * **Lab 03** - [Install Puppet Master](/tutorial/03-Install-Puppet-Master.md)
 * **Lab 04** - [Install Puppet Agent](/tutorial/04-Install-Puppet-Agent.md)
 * **Lab 05** - [Get familiar with puppet config files, and puppet code, and CLI](/tutorial/05-Puppet-Config-and-Code.md)
 * **Lab 06** - [Practice doing some puppet code, and puppet runs](/tutorial/06-Puppet-Code-Practice.md)
 * **Lab 07** - [Configure Hiera](/tutorial/07-Config-Hiera.md)
 * **Lab 08** - [More about Environments](/tutorial/08-Environments.md)
 * **Lab 09** - [Install GitLab on the gitlab VM](/tutorial/09-Install-GitLab.md)
 * **Lab 10** - [Move Puppet Code under Git Control](/tutorial/10-Move-Puppet-Code-to-GitLab.md)
 * **Lab 11** - [Modules, Roles & Profiles, and the environment.conf](/tutorial/11-Roles-and-Profiles.md)
 * **Lab 12** - [Git Basics](/tutorial/12-Git-Basics.md)
 * **Lab 13** - [Git Workflow](/tutorial/13-Git-Workflow.md)
 * **Lab 14** - [Practice doing some puppet code, and puppet runs]
 * **Lab 15** - [Further Reading](/tutorial/YY-Further-Reading.md)



