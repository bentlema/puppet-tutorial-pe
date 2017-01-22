
## Minimum System Requirements

* You will need the ability to install software on your workstation (Admin / Super-User privileges).  We will use the following software:
    - Git
    - VirtualBox
    - Vagrant or Docker

* The software we will use is available for Windows, Linux, and Mac OS X, so you should be able to use any platform.

* Disk space:
    - 20GB of free disk space to acomodate software and VM/Container images

* Memory:
    - minimum 8GB of RAM if using Docker Containers
    - minimum 12GB of RAM if using VirtualBox VMs

* Note: You will use either Vagrant to spin up VM's or Docker to spin up Containers
    - We will not use both (at the same time), so choose one or the other
    - Although Vagrant is capable of spinning up Docker containers, we will
      not use this capability

## Software Versions

As there can be compatibility issues between different versions of the software we will use (e.g. Vagrant and Virtualbox), I would recommend sticking to the versions that have been tested to work together nicely.

| Docker | Vagrant | VirtualBox | Platform                  |
| ------ | ------- | ---------- | ------------------------- |
| 1.13.0 | 1.8.4   | 5.0.28     | Mac OS X 10.11 El Capitan |
|        |         |            | Mac OS X 10.10 Yosemite   |
|        |         |            | Mac OS X 10.9 Mavericks   |
|        |         |            | Linux                     |
|        |         |            | Windows                   |

All of my initial testing has been done using Mac OS X 10.11 El Capitan, Vagrant 1.8.4, and VirtualBox 4.0.28.
Feel free to test other version/platform combinations, and contribute your results here.

