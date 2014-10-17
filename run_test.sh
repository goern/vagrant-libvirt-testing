#!/bin/bash

sudo vagrant plugin register vagrant-libvirt

vagrant plugin list
vagrant up
vagrant ssh omv1 -c 'sudo sh /vagrant/install.sh'
