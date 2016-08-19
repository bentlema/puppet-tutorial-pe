
```
[root@puppet ~]# puppet module install puppetlabs/stdlib
Notice: Preparing to install into /etc/puppetlabs/puppet/environments/production/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/puppet/environments/production/modules
└── puppetlabs-stdlib (v4.11.0)
[root@puppet ~]# puppet config print modulepath
/etc/puppetlabs/puppet/environments/production/modules:/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules
[root@puppet ~]# cd /etc/puppetlabs/puppet/environments/
[root@puppet environments]# mkdir -p development/modules
[root@puppet environments]# puppet module install --environment development puppetlabs/stdlib --version 4.9.1
Notice: Preparing to install into /etc/puppetlabs/puppet/environments/development/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppetlabs/puppet/environments/development/modules
└── puppetlabs-stdlib (v4.9.1)
[root@puppet environments]# tree -L 3 environments/
-bash: tree: command not found
[root@puppet environments]# yum install -y tree
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.web-ster.com
 * extras: mirrors.tummy.com
 * updates: mirrors.gigenet.com
Resolving Dependencies
--> Running transaction check
---> Package tree.x86_64 0:1.6.0-10.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================================================
 Package                                Arch                                     Version                                        Repository                              Size
=============================================================================================================================================================================
Installing:
 tree                                   x86_64                                   1.6.0-10.el7                                   base                                    46 k

Transaction Summary
=============================================================================================================================================================================
Install  1 Package

Total download size: 46 k
Installed size: 87 k
Downloading packages:
tree-1.6.0-10.el7.x86_64.rpm                                                                                                                          |  46 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : tree-1.6.0-10.el7.x86_64                                                                                                                                  1/1
  Verifying  : tree-1.6.0-10.el7.x86_64                                                                                                                                  1/1

Installed:
  tree.x86_64 0:1.6.0-10.el7

Complete!
[root@puppet environments]# tree -L 3 environments/
environments/ [error opening dir]

0 directories, 0 files
[root@puppet environments]# tree -L 3 .
.
├── development
│   └── modules
│       └── stdlib
└── production
    ├── manifests
    │   └── site.pp
    └── modules
        └── stdlib

7 directories, 1 file
[root@puppet environments]# grep '"version":' */modules/stdlib/metadata.json
development/modules/stdlib/metadata.json:  "version": "4.9.1",
production/modules/stdlib/metadata.json:  "version": "4.11.0",
```

