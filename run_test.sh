#!/bin/bash

vagrant up
vagrant ssh omv1 -c 'sudo sh /vagrant/install.sh'
