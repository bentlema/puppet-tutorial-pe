<-- [Back](../README.md#labs)

---

# Lab 1-C #
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
cd docker
ls -l
```

Open up a new Finder window (on Mac) or an Explorer window (on Windows) and navigate to the **share/software/docker** directory, and...

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

Create a Docker Network.  It will be used by the 3 containers we create to communicate with eachother.

```
docker network create --subnet=192.168.198.0/24 example.com
```

Note:  We name our network using what looks like a domain name because docker
will use the network name in the FQDN of the container.  Docker's internal
DNS server will take the short hostname and append the network name when doing
reverse-lookups (PTR records) so we do this little hack to make sure the
forward and reverse lookups match.  With this said, I've seen inconsistant
behavior with Docker's internal DNS, and sometimes reverse lookups just dont work at all.
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
   docker run --detach                   \
      --net example.com                  \
      --ip 192.168.198.12                \
      --publish 24022:22                 \
      --publish 24080:80                 \
      --publish 24443:443                \
      --name gitlab                      \
      --hostname gitlab.example.com      \
      --dns-search example.com           \
      --network-alias gitlab             \
      --network-alias gitlab.example.com \
      --env GITLAB_DATABASE_POOL="3;"    \
      --env GITLAB_OMNIBUS_CONFIG="gitlab_rails['db_pool'] = 3" \
      gitlab/gitlab-ce:latest

```

At this point, all 3 of your Containers should be up and running.  Woot.

---

**BUG ALERT**

For this training, we will simply **NOT** use volumes to keep the important data outside
of the container.  If you were going to run GitLab for real (in production) using the
official Docker container, you would want to use a few volume mappings like this:

```
--volume "${BASEDIR}/gitlab/config:/etc/gitlab"   \
--volume "${BASEDIR}/gitlab/logs:/var/log/gitlab" \
--volume "${BASEDIR}/gitlab/data:/var/opt/gitlab" \
```

Initially I used ${BASEDIR} at the front of my volume paths, but ran into a bug
where GitLab was failing to start due to an error 'filename too long'.  After
changing to a shorter pathname under /tmp, everything worked fine.

The specific error I observed was found in /var/log/gitlab/unicorn/unicorn_stderr.log

```
I, [2016-08-23T02:40:03.851012 #586]  INFO -- : listening on addr=127.0.0.1:8080 fd=13
F, [2016-08-23T02:40:03.855662 #586] FATAL -- : error adding listener addr=/var/opt/gitlab/gitlab-rails/sockets/gitlab.socket
Errno::ENAMETOOLONG: File name too long - connect(2) for /var/opt/gitlab/gitlab-rails/sockets/gitlab.socket
[snip]
bundler: failed to load command: unicorn (/opt/gitlab/embedded/service/gem/ruby/2.3.0/bin/unicorn)
2016-08-23_02:40:04.89988 failed to start a new unicorn master
```

I tested this with GitLab 8.8.8, 8.9.x, 8.10.x, and 8.11.x, and all exhibit this issue.

TODO:  Google a bit and see if I can find an already open bug report on this.
I'm not sure if the issue is related to the entire length of the docker command, or just
the length of the absolute paths used in the **--volume** options.  I did read that there
is some 252 character limit somewhere, but need to do a little more research. All of the
space characters between the **backslashes** count as chars in the command line, so if
that's the issue, we could lose our nice straight column of backslashes to save chars.


---

Continue on to **Lab #2** --> [Prepare to Install Puppet Enterprise](02c-Prep-to-Install-Puppet-Master.md#lab-2-c)

---


