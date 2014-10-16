#!/bin/bash

# update the system and install some basics
yum install -y deltarpm
yum update -y
yum install -y dnf dnf-plugins-core

# enable repo and install vagrant-libvirt
dnf copr enable -y jstribny/vagrant-f20
yum install -y rubygem-vagrant-libvirt
systemctl start libvirtd

# Test case 1 - test libvirt provider
# install oh-my-vagrant for an easy test
git clone https://github.com/purpleidea/oh-my-vagrant.git
cd oh-my-vagrant/vagrant
vagrant up --provider=libvirt && vagrant status

# Test case 2 - test system plugins
vagrant plugin install vagrant-hostmanager
