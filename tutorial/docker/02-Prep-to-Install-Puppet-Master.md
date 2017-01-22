
<-- [Back](01-Provision-Training-Containers.md#labs)

---

# **Lab #2** - Prepare to Install Puppet Enterprise on the **puppet** Container

---

### Overview ###

Time to complete:  5 minutes

In this lab we will prepare to install Puppet Enterprise 2016.5.1

* Make sure your containers started / running
* Get connected to your **puppet** container

### Startup your Training Containers ###

If you've just landed here after doing Lab #1, your containers should already be
up and running and ready to go.

If you're coming back to this tutorial after some downtime, make sure your Docker Containers
are up and running.

To see running containers:

```
   docker ps
```

To see all containers (even those that are stopped):

```
   docker ps -a
```

Make sure your 3 training containers are up and running, and if not, start them:

```
   docker start puppet
   docker start agent
   docker start gitlab
```

Remember that you can connect to your VM's with the exec command of /bin/bash like this:

```
   docker exec -it puppet /bin/bash
```

So do that!  Get connected to your puppet container, and then proceed to the
next lab where we will do the actual install of Puppet Enterprise.

---

Note:  The **puppet** and **agent** containers have been configured from a centos6
image, and sshd has been configured to allow root to login.  The GitLab image,
however, doesn't allow root login with PasswordAuth, so you will need to use
an exec to get into the container if you want to look around.  There's really no
need to use ssh to connect as we work through this tutorial, but I've configured it
just to show that it's possible.

---

### If something goes wrong...

If something goes wrong, and you want to try starting over, you may simply
stop and delete (remove) your container(s) using:

* docker stop ***container-name***
* docker rm ***container-name***

You can use the container name or hash ID to identify the container you want to stop/rm.
After removing a container, you can re-run the **docker run** command to fire up the 
container fresh.


---

Continue to **Lab #3** --> [Install Puppet Master](03-Install-Puppet-Master.md#lab-3)

---

Copyright © 2016 by Mark Bentley

