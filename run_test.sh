#!/bin/bash

export PATH="/bin:/usr/bin"

sudo vagrant plugin register vagrant-libvirt

vagrant plugin list
vagrant up
vagrant ssh omv1 -c 'sudo sh /vagrant/install.sh'

vagrant destroy omv1
rm -rf .vagrant.d vagrant.yml
