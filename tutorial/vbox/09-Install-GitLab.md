<-- Back to **Lab #8** - [More about Environments](08-Environments.md#lab-8)

---

### **Lab #9** - Install GitLab

---

### Overview ###

Note:  if you're running with less than 10GB of memory (like on an 8GB system), you may want to start only the **puppet** and **gitlab** virtual machines for this lab to save memory (don't start the **agent** VM, as we wont need it.)
When running all 3 VM's on an 8GB system, you may start to swap and your workstation may start to crawl and/or freeze up...Close any applications you don't need running to help conserve memory, or get a better workstations.
Geesh.

### Start up your GitLab VM

You should have already created your **gitlab** VM, but if not, go ahead and do it now...

```
     vagrant up gitlab     # bring up your VM
     vagrant ssh gitlab    # ssh in to get a shell
     sudo su -             # become root
```

### Install the Puppet Agent

Although not required for our training environment, let's install the Puppet
Agent on our GitLab VM so that our timezone is set, and NTP is configured to
run.  Review [Lab #4](04-Install-Puppet-Agent.md) for instructions on how to
install the agent, but it basically goes like this:

```
[root@gitlab ~]# echo '
127.0.0.1      localhost
192.168.198.10 puppet.example.com  puppet
192.168.198.11 agent.example.com   agent
192.168.198.12 gitlab.example.com  gitlab' > /etc/hosts

[root@gitlab ~]# cd /tmp
[root@gitlab ~]# curl -k --tlsv1 https://192.168.198.10:8140/packages/current/install.bash
[root@gitlab ~]# chmod a+rx install.bash
[root@gitlab ~]# ./install.bash agent:certname=gitlab.example.com
```

Sign the cert on the puppet master, and then run **puppet agent -t** on gitlab...

```
Error: Could not retrieve catalog from remote server: Error 400 on SERVER: Could not find data item location in any Hiera data file and no default supplied at /etc/puppetlabs/puppet/environments/production/manifests/site.pp:43 on node gitlab.example.com
```

We need to create a node yaml file for **gitlab.example.com** on the puppet master...

```
[root@puppet ~]# cd /etc/puppetlabs/puppet/environments/production/data/node/
[root@puppet node]# cp agent.example.com.yaml gitlab.example.com.yaml
[root@puppet node]# cat gitlab.example.com.yaml
---

location: amsterdam

classes:
   - ntp
   - timezone

timezone::timezone: 'US/Pacific'
```

That should be fine for now...Run puppet again and you should get a clean run...



### GitLab Installation Instructions

A summary of the minimal installation structions for GitLab follow...
(Full instructions are [here](https://about.gitlab.com/downloads/#centos7))

- Install and configure the necessary dependencies

```
     # These should already be installed and running, but just in case...
     yum install -y openssh-server postfix
     yum install -y postfix
     systemctl enable postfix
     systemctl start postfix
```

- Open the host firewall to allow in-bound HTTP.  Although GitLab uses HTTP by default, it is possible to re-configure it to use HTTPS.  We won't go through that process in this training, but you may find the instructions [HERE](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md)

```
     # Let inbound HTTP through the firewall so we can hit the GitLab web interface
     firewall-cmd --permanent --add-service=http
     systemctl reload firewalld
```

- Add the GitLab package server and install the package

```
     curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
     yum install -y gitlab-ce
```

- Configure and start GitLab

```
     gitlab-ctl reconfigure
```

- Browse to <http://127.0.0.1:24080/> and login
     - Login with:
       - Username: root
       - Password: 5iveL!fe
     - You'll be prompted to change the root password, so go ahead and do that.

- As the 'root' user, create a user account for yourself
     - Click the `wrench` icon in the top-right corner called the **Admin Area**
     - Click **Users** tab
     - Click **New User** in the main pane and fill out the required info
       - Use a valid email, as the account creation process will send you a password reset link
       - In the **Access** section, check the **Admin** box to make this account and admin account
       - Also make sure `Can create a group` is checked
     - Click on the **Create User** button at the bottom of the form
     - Logout the root user
     - You should receive an email to the e-mail address you provided in the account creation form
       - The link to set your password will not work, but you may copy it and edit it to point to localhost like this:
       ```
       http://localhost:24080/users/password/edit?reset_password_token=Zo9b6dFY4Ld7YvvW7iCC
       ```
     - Next try logging in as yourself using the account you just created and set the password for
       - Note:  if unable to get the reset link to work, you can also set the password via the webGUI

- Once your are logged in as yourself (as the user you just created) the continue...

- Create a group called `puppet`
     - If you click on the GitLab icon in the top-left, you should land on the main 'Your Projects' page, or for new accounts, you should see 'Greate New Group' link on the landing page
     - Click on **New Group**
     - Enter the group name `puppet`
     - Select **Public**
     - click **Create Group**
     - Note: since you've created the group, you are the **Owner** and will have access to any projects (repos) within that group

- Create a project called `control` and set the Namespace to be the `puppet` group
     - Click on the GitLab icon in the top-left, to get back to the main 'Your Projects' page
     - Click **New Project** and change the Namespace to `puppet` instead of yourself
     - The remaining options can be left at their defaults
     - Select **Public** visibility here too
     - Click **Create Project**

-  Configure your GitLab account to allow you to clone/pull/push to the puppet/control repo
     - If you already have your own personal public/private key pair for SSH, you may use it
     - If you don't already have a key, you can generate one with ssh-keygen
     - Add your **public** key to your GitLab account under **Profile Settings -> SSH Keys**
     - Add a config section to your ~/.ssh/config to tell ssh what **private** key to use, as well as what user and port

```
  Host localhost
    User git
    Port 24022
    IdentityFile /Users/Mark/.ssh/id_rsa.gitlab-mark
```

You should now be able to clone your repo. But first, make sure you've set your Name and Email in your Git client config so that your commits show who you are:

For example:

```
git config --global user.name "Mark Bentley"
git config --global user.email "bentlema@yahoo.com"
```

Next, try to clone the puppet/control repo from GitLab:

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training] $ git clone ssh://localhost/puppet/control.git
Cloning into 'control'...
The authenticity of host '[localhost]:24022 ([127.0.0.1]:24022)' can't be established.
RSA key fingerprint is 25:cb:6c:9c:da:4e:6f:46:72:75:46:ac:18:19:31:ee.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[localhost]:24022' (RSA) to the list of known hosts.
warning: You appear to have cloned an empty repository.
Checking connectivity... done.

MBP-MARK:[/Users/Mark/Git/Puppet-Training] $ cd control

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] $ git remote -v
origin  ssh://localhost/puppet/control.git (fetch)
origin  ssh://localhost/puppet/control.git (push)

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] $ vi README.md
```

Put some text in to your README.md such as 'Hello World' then add that file and commit it.

```
MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] *$ git add README.md

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] *$ git commit -m 'First commit'
[master (root-commit) 276c800] First commit
 1 file changed, 2 insertions(+)
 create mode 100644 README.md

MBP-MARK:[/Users/Mark/Git/Puppet-Training/control] (master)$ git push
Counting objects: 3, done.
Writing objects: 100% (3/3), 231 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://localhost/puppet/control.git
 * [new branch]      master -> master
```

Now go back to the GitLab webGUI and take a look at the file you just pushed.


---

Continue on to **Lab #10** --> [Move Puppet Code under Git Control](10-Move-Puppet-Code-to-GitLab.md#lab-10)

---

See Also:

    - Installation Instructions:      <https://about.gitlab.com/downloads/#centos7>
    - GitLab Omnibus Documentation:   <http://doc.gitlab.com/omnibus/>
    - Configure GitLab to use HTTPS:  <https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md>

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

