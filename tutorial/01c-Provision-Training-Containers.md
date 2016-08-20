<-- [Back](../README.md#start-here)

---

## Lab 1-C ##
### Install software, and use Docker to deploy 3 training Containers ###

---

### Overview ###

Time to complete:  30 minutes

The following software should already be installed:

* **Git** - the version control system

In this lab you will install the following software:

* **Docker** - the container deployment tool

...and then create 3 containers named as follows:

1. **puppet**   (Puppet Master, PE Console, etc.)
3. **agent**    (A Puppet agent)
2. **gitlab**   (the Git Hosting Software)

### Download Software ###

* Download the needed software for this training...

```
[puppet-training/share]$ cd software
[puppet-training/share/software]$ ./download-all.sh
```

### Installing Docker ###

After running the **download-all.sh** Find the appropriate installer for
Mac or Windows in the **share/software/docker** folder.

```
cd share/software/docker
```

* On Mac OS X, double-click the Docker.dmg, and then double-click the installer
* On Windows double-click the .msi file to launch the installer
* If you're running Linux, Docker runs natively, so you just need to install the docker-engine package.
  See:  <https://docs.docker.com/engine/installation/linux/>

### Some Docker Basics ###

```
   docker help   # see help page
   docker ps     # see running containers
   docker ps -a  # See all containers
   docker images # show local docker images
   docker rmi    # remove an image
   docker run    # create and run a container
   docker stop   # stop a container
   docker rm     # remove a stopped container
```

### Creating A Private Docker Network ###

Create Docker Network which will be used by the 3 containers we will create
  - Each of the 3 containers will be able to communicate with eachother over
    this private-internal-to-docker network
  - Example: Puppet agents will talk to the Puppet master over this network
  - Example: R10K will pull code from the GitLab server over this network

```
docker network create --subnet=192.168.198.0/24 example.com
```

Note:  We name our network using what looks like a domain name because docker
will use the network name in the FQDN of the container.  Docker's internal
DNS server will take the short hostname and append the network name when doing
reverse-lookups (PTR records) so we do this little hack to make sure the
forward and reverse lookups match.  With this said, I've seen inconsistant
behavior with Docker's internal DNS, and sometimes reverse lookups just dont work.
No matter, we push on!


### Setup ENV variable with your BASEDIR ###

I don't know where you've cloned this puppet-training repo to on your
workstation.  So, let's make our lives simpler, and set an ENV variable
to contain the absolute path to your working tree (top level of the repo)

Make sure your current working directory is the top level of the puppet-training
repo, and then just type this:

```
   export BASEDIR=$(pwd)
```

Then validate that BASEDIR is set to what you want:

```
   echo $BASEDIR
```

And you should see something like this:

```
$ pwd
/Users/mbentle8/Documents/Git/Bitbucket/puppet-training

$ export BASEDIR=$(pwd)

$ echo $BASEDIR
/Users/mbentle8/Documents/Git/Bitbucket/puppet-training

```

Now, as you'll see in the following sections, we will use **${BASEDIR}** in the docker
command when specifying the absolute path to our volumes.  If you dont specify the
absolute path, the volume mapping will not work as expected.  So, rather than having
to type out the entire path each time, we save it in BASEDIR.


### Create and run your Puppet Master Container ###

To start up the container for the Puppet Master:

```
   docker run -d                         \
      --memory 4G                        \
      --net example.com                  \
      --ip 192.168.198.10                \
      -p 22022:22                        \
      -p 22443:443                       \
      -p 22080:8080                      \
      -p 22081:8081                      \
      -p 22140:8140                      \
      -p 22000:3000                      \
      --name puppet                      \
      --hostname puppet.example.com      \
      --dns-search=example.com           \
      --network-alias=puppet             \
      --network-alias=puppet.example.com \
      --volume ${BASEDIR}/share:/share   \
      bentlema/centos6-puppet-nocm       \
      /sbin/init
```

You've just started up your puppet container, and left it running in the background.

To see your running containers do:

```
   docker ps
```

### Login to the puppet container ###

```
docker exec -it puppet /bin/bash
```

*OR*

```
ssh -l root localhost -p 22022
```
The default password is:  *foobar23*


### Create and run your agent container ###

```
   docker run -d                        \
      --memory 512M                     \
      --net example.com                 \
      --ip 192.168.198.11               \
      -p 23022:22                       \
      --name agent                      \
      --hostname agent.example.com      \
      --dns-search=example.com          \
      --network-alias=agent             \
      --network-alias=agent.example.com \
      --volume ${BASEDIR}/share:/share  \
      bentlema/centos6-puppet-nocm      \
      /sbin/init
```

### Create and run GitLab container ###

Notice that the container image we're using is from *gitlab* itself.  That's
the nice thing about Docker.  There are many pre-built container images
that we can just use, and instantly have a nice piece of software up and
running without any fuss.


```
   docker run -d                                      \
      --memory 2G                                     \
      --net example.com                               \
      --ip 192.168.198.12                             \
      -p 24022:22                                     \
      -p 24080:80                                     \
      -p 24443:443                                    \
      --name gitlab                                   \
      --hostname gitlab.example.com                   \
      --dns-search example.com                        \
      --network-alias gitlab                          \
      --network-alias gitlab.example.com              \
      --restart always                                \
      --volume ${BASEDIR}/gitlab/config:/etc/gitlab   \
      --volume ${BASEDIR}/gitlab/logs:/var/log/gitlab \
      --volume ${BASEDIR}/gitlab/data:/var/opt/gitlab \
      --volume ${BASEDIR}/share:/share                \
      gitlab/gitlab-ce
```

At this point, all 3 of your Containers should be up and running.  Woot.

---

Continue on to **Lab #2** --> [Prepare to Install Puppet Enterprise](02c-Prep-to-Install-Puppet-Master.md)

---


