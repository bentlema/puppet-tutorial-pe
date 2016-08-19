# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # These are the default settings, but we can override them on a per-VM basis
  # config.vm.box = "centos/7"
  config.vm.box = "puppetlabs/centos-7.2-64-nocm"
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
  config.vm.synced_folder "share", "/vagrant", disabled: false
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "512"
    vb.cpus = "1"
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Update the VM with latest Centos packages, and re-install NetworkManager to work-around nmcli bug
  config.vm.provision "shell", inline: "yum clean all && yum update -y && yum reinstall -y NetworkManager"

  # Our Puppet Server (CA, Master compile host, puppetDB, PE Console, etc.)
  config.vm.define "puppet" do |puppet|
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = "2"
    end
    puppet.vm.hostname = "puppet"
    puppet.vm.network "private_network",   ip: "192.168.198.10"
    puppet.vm.network "forwarded_port", guest:   22, host: 22022, id: 'ssh'
    puppet.vm.network "forwarded_port", guest:  443, host: 22443 # Enterprise Console (HTTP)
    puppet.vm.network "forwarded_port", guest: 8080, host: 22080 # PuppetDB (HTTP)
    puppet.vm.network "forwarded_port", guest: 8081, host: 22081 # PuppetDB (HTTPS)
    puppet.vm.network "forwarded_port", guest: 8140, host: 22140 # Puppet Master (HTTP)
    puppet.vm.network "forwarded_port", guest: 3000, host: 22000 # Used during PE Installation (HTTPS)
  end

  config.vm.define "agent" do |agent|
    agent.vm.hostname = "agent"
    agent.vm.network "private_network",    ip: "192.168.198.11"
    agent.vm.network "forwarded_port",  guest:   22, host: 23022, id: 'ssh'
  end

  config.vm.define "gitlab" do |gitlab|
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    gitlab.vm.hostname = "gitlab"
    gitlab.vm.network "private_network",   ip: "192.168.198.12"
    gitlab.vm.network "forwarded_port", guest:   22, host: 24022, id: 'ssh'
    gitlab.vm.network "forwarded_port", guest:   80, host: 24080 # GitLab Web GUI (HTTP)
    gitlab.vm.network "forwarded_port", guest:  443, host: 24443 # GitLab Web GUI (HTTPS)
  end


end


