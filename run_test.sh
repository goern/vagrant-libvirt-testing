#!/bin/bash

sudo vagrant plugin register vagrant-libvirt

vagrant plugin list
vagrant up
vagrant ssh vlvt1 -c 'sudo sh /vagrant/install.sh'
