
<-- [Back](/tutorial/01c-Provision-Training-Containers.md)

---

### Lab #2-C - Prepare to Install Puppet Enterprise on the **puppet** Container ###

---

### Overview ###

Time to complete:  5 minutes

In this lab we will prepare to install Puppet Enterprise 3.8.X

* PE is free to install and evaluate
* When running PE without a license, you're limited to 10 agents

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

Remember that you can connect to your VM's with the exec command like this:

```
   docker exec -it puppet /bin/bash
   docker exec -it agent  /bin/bash
   docker exec -it gitlab /bin/bash
```

Note:  The puppet and agent containers have been configured from a centos6
image, and sshd has been configured to allow root to login.  The GitLab image,
however, doesn't allow root login with PasswordAuth, so you will need to use
an exec to get into the container if you want to look around.

---

Continue to **Lab #3** --> [Install Puppet Master](03-Install-Puppet-Master.md)

---

