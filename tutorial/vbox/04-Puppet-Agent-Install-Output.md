
Here's the output from the agent install...

```
[root@agent ~]# wget --no-check-certificate --secure-protocol=TLSv1 -O - https://puppet:8140/packages/current/install.bash | bash -s agent:certname=agent.example.com
--2016-11-14 21:43:12--  https://puppet:8140/packages/current/install.bash
Resolving puppet (puppet)... 192.168.198.10
Connecting to puppet (puppet)|192.168.198.10|:8140... connected.
WARNING: cannot verify puppet's certificate, issued by ‘/CN=Puppet Enterprise CA generated on puppet.example.com at +2016-11-14 18:16:25 +0000’:
  Unable to locally verify the issuer's authority.
HTTP request sent, awaiting response... 200 OK
Length: 20106 (20K)
Saving to: ‘STDOUT’

100%[======================================================================>] 20,106      --.-K/s   in 0s

2016-11-14 21:43:12 (345 MB/s) - written to stdout [20106/20106]

Loaded plugins: fastestmirror
Cleaning repos: pe_repo
Cleaning up everything
Cleaning up list of fastest mirrors
Loaded plugins: fastestmirror
base                                                                                     | 3.6 kB  00:00:00
extras                                                                                   | 3.4 kB  00:00:00
pe_repo                                                                                  | 2.5 kB  00:00:00
updates                                                                                  | 3.4 kB  00:00:00
pe_repo/primary_db                                                                       |  24 kB  00:00:00
Determining fastest mirrors
 * base: mirror.millry.co
 * extras: mirror.eboundhost.com
 * updates: mirror.atlantic.net
Error: No matching Packages to list
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.millry.co
 * extras: mirror.eboundhost.com
 * updates: mirror.atlantic.net
Resolving Dependencies
--> Running transaction check
---> Package puppet-agent.x86_64 0:1.7.1-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================================================
 Package                      Arch                   Version                      Repository               Size
================================================================================================================
Installing:
 puppet-agent                 x86_64                 1.7.1-1.el7                  pe_repo                  24 M

Transaction Summary
================================================================================================================
Install  1 Package

Total download size: 24 M
Installed size: 114 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/pe_repo/packages/puppet-agent-1.7.1-1.el7.x86_64.rpm: Header V4 RSA/SHA1 Signature, key ID ef8d349f: NOKEY
Public key for puppet-agent-1.7.1-1.el7.x86_64.rpm is not installed
puppet-agent-1.7.1-1.el7.x86_64.rpm                                                      |  24 MB  00:00:00
Retrieving key from https://puppet.example.com:8140/packages/GPG-KEY-puppetlabs
Importing GPG key 0x4BD6EC30:
 Userid     : "Puppet Labs Release Key (Puppet Labs Release Key) <info@puppetlabs.com>"
 Fingerprint: 47b3 20eb 4c7c 375a a9da e1a0 1054 b7a2 4bd6 ec30
 From       : https://puppet.example.com:8140/packages/GPG-KEY-puppetlabs
Retrieving key from https://puppet.example.com:8140/packages/GPG-KEY-puppet
Importing GPG key 0xEF8D349F:
 Userid     : "Puppet, Inc. Release Key (Puppet, Inc. Release Key) <release@puppet.com>"
 Fingerprint: 6f6b 1550 9cf8 e59e 6e46 9f32 7f43 8280 ef8d 349f
 From       : https://puppet.example.com:8140/packages/GPG-KEY-puppet
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : puppet-agent-1.7.1-1.el7.x86_64                                                              1/1
  Verifying  : puppet-agent-1.7.1-1.el7.x86_64                                                              1/1

Installed:
  puppet-agent.x86_64 0:1.7.1-1.el7

Complete!
service { 'puppet':
  ensure => 'stopped',
}
Notice: /Service[puppet]/ensure: ensure changed 'stopped' to 'running'
service { 'puppet':
  ensure => 'running',
  enable => 'true',
}
service { 'puppet':
  ensure => 'running',
  enable => 'true',
}
Notice: /File[/usr/local/bin/facter]/ensure: created
file { '/usr/local/bin/facter':
  ensure => 'link',
  target => '/opt/puppetlabs/puppet/bin/facter',
}
Notice: /File[/usr/local/bin/puppet]/ensure: created
file { '/usr/local/bin/puppet':
  ensure => 'link',
  target => '/opt/puppetlabs/puppet/bin/puppet',
}
Notice: /File[/usr/local/bin/pe-man]/ensure: created
file { '/usr/local/bin/pe-man':
  ensure => 'link',
  target => '/opt/puppetlabs/puppet/bin/pe-man',
}
Notice: /File[/usr/local/bin/hiera]/ensure: created
file { '/usr/local/bin/hiera':
  ensure => 'link',
  target => '/opt/puppetlabs/puppet/bin/hiera',
}
[root@agent ~]# puppet agent -t

```


---

Back to **Lab #4** --> [Install Puppet Agent](04-Install-Puppet-Agent.md#install-the-agent)

---

<-- [Back to Contents](/README.md)

---

Copyright © 2016 by Mark Bentley

