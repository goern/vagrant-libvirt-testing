# -*- mode: ruby -*-
# vi: set ft=ruby :

# This is: Oh My Vagrant!
# Copyright (C) 2012-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# TODO: the /etc/hosts DNS setup is less than ideal, but I didn't implement
# anything better yet. Please feel free to suggest something else!

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

require 'ipaddr'
require 'yaml'

#
#	globals
#
# thanks to the gluster.org community for the public box hosting
default_boxurlprefix = 'https://download.gluster.org/pub/gluster/purpleidea/vagrant'

# XXX: eliminate network2 if possible...
network2 = IPAddr.new '192.168.145.0/24'
range2 = network2.to_range.to_a
cidr2 = (32-(Math.log(range2.length)/Math.log(2))).to_i
offset2 = 2
netmask2 = IPAddr.new('255.255.255.255').mask(cidr2).to_s

#
#	vms
#
# NOTE: you can specify the list of vms here, or in the vagrant.yaml file...
# NOTE: if you set the vagrant vms array to nil, you'll default to this list
vms = [
#	{:name => 'example1', :docker => true, :puppet => true, },	# example1
#	{:name => 'example2', :docker => ['centos', 'fedora'], },	# example2
#	{:name => 'example3', :docker =>
#		[
#			{:name => 'centos', },
#			{:name => 'fedora', },
#		],
#	},								# example3
#	{:name => 'example4', :image => 'centos-6', :puppet => true, },	# example4
#	{:name => 'example5', :image => 'rhel-7.0', :poolid => true, },	# example5
]

# mutable by ARGV and settings file
domain = 'example.com'		# demain domain to use (yes this *can* work)
network = '192.168.123.0/24'	# default network to use
image = 'fedora-20'		# default image name
boxurlprefix = ''		# default url prefix (useful for private boxes)
sync = 'rsync'			# default sync type
puppet = false			# default use of puppet or not
docker = false			# default use of docker or not
cachier = false			# default cachier usage
#vms = []			# default list of vms to build (special global)
namespace = 'omv'		# default namespace
count = 1			# default number of hosts to build
# TODO: subscription manager needs to grow a way to generate an 'API key' that
# can be used instead of a password so that it can be safely used in scripts...
username = ''			# default subscription manager username
password = ''			# default subscription manager password
poolid = []			# default list of poolid's (true to auto-attach)
repos = []			# default list of extra repos's to enable

def array_values_to_array_of_hashes(l)
	result = l
	if l.is_a?(Array) and l.length > 0
		if not l[0].is_a?(Hash)	# check the first value
			result = l.each_with_object([]) { |x, a| a.push({:name => x}) }
		end
	end
	return result
end

#
#	ARGV parsing
#
projectdir = File.expand_path File.dirname(__FILE__)	# vagrant project dir!!
f = File.join(projectdir, 'vagrant.yaml')

# load settings
if File.exist?(f)
	settings = YAML::load_file f
	domain = settings[:domain]
	network = settings[:network]
	image = settings[:image]
	boxurlprefix = settings[:boxurlprefix]
	sync = settings[:sync]
	puppet = settings[:puppet]
	docker = settings[:docker]
	cachier = settings[:cachier]
	if settings[:vms].is_a?(Array)
		vms = settings[:vms]
	end
	namespace = settings[:namespace]
	count = settings[:count]
	username = settings[:username]
	password = settings[:password]
	poolid = settings[:poolid]
	repos = settings[:repos]
end

# ARGV parser
skip = 0
while skip < ARGV.length
	#puts "#{skip}, #{ARGV[skip]}"	# debug
	if ARGV[skip].start_with?(arg='--vagrant-domain=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg
		#puts "#{arg}, #{v}"	# debug

		domain = v.to_s		# set domain

	elsif ARGV[skip].start_with?(arg='--vagrant-network=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		network = v.to_s	# set network range

	elsif ARGV[skip].start_with?(arg='--vagrant-image=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		image = v.to_s	# set base image

	elsif ARGV[skip].start_with?(arg='--vagrant-boxurlprefix=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		boxurlprefix = v.to_s	# set box url prefix

	elsif ARGV[skip].start_with?(arg='--vagrant-sync=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		sync = v.to_s		# set sync type

	elsif ARGV[skip].start_with?(arg='--vagrant-puppet=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		puppet = v.to_s		# set puppet flag
		if ['true', 'yes'].include?(puppet.downcase)
			puppet = true
		else
			puppet = false
		end

	elsif ARGV[skip].start_with?(arg='--vagrant-docker=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		if v.is_a?(String) and v.include? ',' and v.split(',').length > 0
			v = v.split(',')
			docker = array_values_to_array_of_hashes(v)
		else
			docker = v.to_s		# set puppet flag
			if ['true', 'yes'].include?(docker.downcase)
				docker = true
			else
				docker = false
			end
		end

	elsif ARGV[skip].start_with?(arg='--vagrant-cachier=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		cachier = v.to_s	# set cachier flag
		if ['true', 'yes'].include?(cachier.downcase)
			cachier = true
		else
			cachier = false
		end

	elsif ARGV[skip].start_with?(arg='--vagrant-vms=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		if v.is_a?(String) and v.include? ',' and v.split(',').length > 0
			v = v.split(',')
			vms = array_values_to_array_of_hashes(v)
		end

	elsif ARGV[skip].start_with?(arg='--vagrant-namespace=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		namespace = v.to_s	# set namespace

	elsif ARGV[skip].start_with?(arg='--vagrant-count=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		count = v.to_i		# set host count

	elsif ARGV[skip].start_with?(arg='--vagrant-username=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		username = v.to_s	# set username

	elsif ARGV[skip].start_with?(arg='--vagrant-password=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		password = v.to_s	# set password

	elsif ARGV[skip].start_with?(arg='--vagrant-poolid=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		if v.is_a?(String) and v.include? ',' and v.split(',').length > 0
			poolid = v.split(',')
		else
			poolid = v.to_s		# set poolid boolean flag
			if ['true', 'auto'].include?(poolid.downcase)
				poolid = true
			else
				poolid = false
			end
		end

	elsif ARGV[skip].start_with?(arg='--vagrant-repos=')
		v = ARGV.delete_at(skip).dup
		v.slice! arg

		if v.is_a?(String) and v.include? ',' and v.split(',').length > 0
			repos = v.split(',')
		else
			repos = v.to_s		# set repos boolean flag
			if ['true', 'all'].include?(repos.downcase)
				repos = true
			else
				repos = false
			end
		end

	else	# skip over "official" vagrant args
		skip = skip + 1
	end
end

# save settings (ARGV overrides)
settings = {
	:domain => domain,
	:network => network,
	:image => image,
	:boxurlprefix => boxurlprefix,
	:sync => sync,
	:puppet => puppet,
	:docker => docker,
	:cachier => cachier,
	:vms => vms,
	:namespace => namespace,
	:count => count,
	:username => username,
	:password => password,
	:poolid => poolid,
	:repos => repos,
}
File.open(f, 'w') do |file|
	file.write settings.to_yaml
end

#puts "ARGV: #{ARGV}"	# debug

# networking
network_obj = IPAddr.new network
range = network_obj.to_range.to_a
cidr = (32-(Math.log(range.length)/Math.log(2))).to_i
offset = 100		# start hosts after here
#puts range[0].to_s	# network
#puts range[1].to_s	# router (reserved)
#puts range[2].to_s	# puppetmaster
#puts range[3].to_s	# vip

# prepend $count vms onto the vms list...
extra = []
(1..count).each do |i|
	h = "#{namespace}#{i}"
	# generate names and add in the defaults
	extra.push({:name => h, :docker => docker})
end
vms = extra.concat vms

# add in puppet host if requested
if puppet
	extra = [{:name => 'puppet'}]
	vms = extra.concat vms
end

# transform docker value if necessary
docker = array_values_to_array_of_hashes(docker)

# erase host information from puppet so that the user can do partial rebuilds
snoop = ARGV.select { |x| !x.start_with?('-') }
if snoop.length > 1 and snoop[0] == 'destroy'
	snoop.shift	# left over array snoop should be list of hosts
	if snoop.include?('puppet')	# doesn't matter then...
		snoop = []
	end
else
	# important! clear snoop because we're not using 'destroy'
	snoop = []
end

# figure out which hosts are getting destroyed
destroy = ARGV.select { |x| !x.start_with?('-') }
if destroy.length > 0 and destroy[0] == 'destroy'
	destroy.shift	# left over array destroy should be list of hosts or []
	if destroy.length == 0
		destroy = true	# destroy everything
	end
else
	destroy = false		# destroy nothing
end

# figure out which hosts are getting provisioned
provision = ARGV.select { |x| !x.start_with?('-') }
if provision.length > 0 and ['up', 'provision'].include?(provision[0])
	provision.shift	# left over array provision should be list of hosts or []
	if provision.length == 0
		provision = true	# provision everything
	end
else
	provision = false		# provision nothing
end

# XXX: workaround for: https://github.com/mitchellh/vagrant/issues/2447
# only run on 'vagrant init' or if it's the first time running vagrant
if sync == 'nfs' and ((ARGV.length > 0 and ARGV[0] == 'init') or not(File.exist?(f)))
	`sudo systemctl restart nfs-server`
	`firewall-cmd --permanent --zone public --add-service mountd`
	`firewall-cmd --permanent --zone public --add-service rpc-bind`
	`firewall-cmd --permanent --zone public --add-service nfs`
	`firewall-cmd --reload`
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	#config.landrush.enable	# TODO ?

	#
	#	sync type
	#
	config.vm.synced_folder './', '/vagrant', type: sync	# nfs, rsync

	#
	#	cache
	#
	# NOTE: you should probably erase the cache between rebuilds if you are
	# installing older package versions. This is because the newer packages
	# will get cached, and then subsequently might get silently installed!!
	if cachier
		# TODO: this doesn't cache metadata, full offline operation not possible
		config.cache.auto_detect = true
		config.cache.enable :yum
		#config.cache.enable :apt
		if not ARGV.include?('--no-parallel')	# when running in parallel,
			config.cache.scope = :machine	# use the per machine cache
		end
		if sync == 'nfs'	# TODO: support other sync types here...
			config.cache.enable_nfs = true	# sets nfs => true on the synced_folder
			# the nolock option is required, otherwise the NFSv3 client will try to
			# access the NLM sideband protocol to lock files needed for /var/cache/
			# all of this can be avoided by using NFSv4 everywhere. die NFSv3, die!
			config.cache.mount_options = ['rw', 'vers=3', 'tcp', 'nolock']
		end
	end

	#
	#	vip
	#
	vip_ip = range[3].to_s
	vip_hostname = namespace

	#
	#	vms mainloop to define all the machines
	#
	vms.each_with_index do |x, i|
		h = x[:name]
		ip = range[offset+i].to_s
		#fqdn = "#{h}.#{domain}"
		vm_image = x.fetch(:image, image)	# get value
		vm_docker = x.fetch(:docker, docker)	# get value
		vm_docker = array_values_to_array_of_hashes(vm_docker)
		vm_puppet = x.fetch(:puppet, puppet)	# get value
		vm_poolid = x.fetch(:poolid, poolid)	# get value
		vm_repos = x.fetch(:repos, repos)	# get value

		config.vm.define h.to_sym do |vm|
			vm.vm.hostname = h
			# red herring network so that management happens here...
			vm.vm.network :private_network,
			:ip => range2[offset2+i].to_s,
			:libvirt__netmask => netmask2,
			#:libvirt__dhcp_enabled => false,	# XXX: not allowed here
			:libvirt__network_name => 'default'

			# this is the real network that we'll use...
			vm.vm.network :private_network,
			:ip => ip,
			:libvirt__dhcp_enabled => false,
			:libvirt__network_name => "#{namespace}"

			#
			#	box (pre-built base image)
			#
			vm.vm.box = vm_image	# set vm specific image

			# use a specialized vagrant box if it exists :)
			if vm_docker
				if `vagrant box list | grep -q '^#{vm_image}-docker' && echo -n found` != ''
					vm.vm.box = "#{vm_image}-docker"
				end
			end

			# box source url's
			# FIXME: boxes should be GPG signed and verified on dl!
			if "#{boxurlprefix}" != ''
				vm.vm.box_url = "#{boxurlprefix}#{vm.vm.box}/#{vm.vm.box}.box"
			end

			# FIXME: speed up or cache (memoize) this check...
			if `vagrant box list | grep -q '^#{vm.vm.box}' && echo -n found` != ''
				exists = true
			else
				if vm.vm.box_url.is_a?(String)
					puts "Running wget check on: '#{vm.vm.box_url}'"
					exists = `wget -q --spider #{vm.vm.box_url}`
				else
					exists = false
				end
			end
			if not(exists) and not vm.vm.box.start_with? 'rhel-'
				vm.vm.box_url = "#{default_boxurlprefix}/#{vm.vm.box}/#{vm.vm.box}.box"
			end

			#vm.landrush.host h, ip	# TODO ?

			fv = File.join(projectdir, '.vagrant', "#{h}-hosts.done")
			if destroy.is_a?(TrueClass) or (destroy.is_a?(Array) and destroy.include?(h))
				if File.exists?(fv)	# safety
					puts "Unlocking shell provisioning for: #{h}..."
					File.delete(fv)	# delete hosts token
				end
			end

			# should we clean this puppet client machine?
			if puppet and vm_puppet and h != 'puppet' and snoop.include?(h)
				cmd = "puppet cert clean #{h}.#{domain}"
				puts "Running 'puppet cert clean' for: #{h}..."
				`vagrant ssh puppet -c 'sudo #{cmd}'`
				cmd = "puppet node deactivate #{h}.#{domain}"
				puts "Running 'puppet node deactivate' for: #{h}..."
				`vagrant ssh puppet -c 'sudo #{cmd}'`
			end

			# unsubscribe rhel machines on destroy
			if destroy.is_a?(TrueClass) or (destroy.is_a?(Array) and destroy.include?(h))
				if vm.vm.box.start_with? 'rhel-'
					# check these to know if we registered!
					if username != '' and password != ''
						# ssh into itself and unregister
						cmd = 'subscription-manager unregister'
						puts "Running '#{cmd}' on: #{h}..."
						puts `vagrant ssh #{h} -c 'sudo #{cmd}'`
					end
				end
			end

			#
			#	shell
			#
			if not File.exists?(fv)	# only modify /etc/hosts once
				if provision.is_a?(TrueClass) or (provision.is_a?(Array) and provision.include?(h))
					File.open(fv, 'w') {}	# touch
				end
				vm.vm.provision 'shell', inline: 'puppet resource host localhost.localdomain ip=127.0.0.1 host_aliases=localhost'
				vm.vm.provision 'shell', inline: "puppet resource host #{h} ensure=absent"	# so that fqdn works

				vm.vm.provision 'shell', inline: "puppet resource host #{vip_hostname}.#{domain} ip=#{vip_ip} host_aliases=#{vip_hostname} ensure=present"
				#vm.vm.provision 'shell', inline: "[ ! -e /root/puppet-cert-is-clean ] && ssh -o 'StrictHostKeyChecking=no' puppet puppet cert clean #{h}.#{domain} ; touch /root/puppet-cert-is-clean"
				# hosts entries for all hosts
				vms.each_with_index do |x, j|
					oh = x[:name]
					oip = range[offset+j].to_s	# eg: "192.168.142.#{100+i}"
					vm.vm.provision 'shell', inline: "puppet resource host #{oh}.#{domain} ip=#{oip} host_aliases=#{oh} ensure=present"
				end

				# subscribe rhel machines
				if vm.vm.box.start_with? 'rhel-'
					if username != '' and password != ''
						vm.vm.provision 'shell', inline: "subscription-manager register --username=#{username} --password=#{password}"
					end

					# attach correct pools
					if vm_poolid.is_a?(Array)
						vm_poolid.each do |j|
							vm.vm.provision 'shell', inline: "subscription-manager attach --pool=#{j}"
						end

					elsif vm_poolid
						# auto attach if value is true
						vm.vm.provision 'shell', inline: 'subscription-manager attach --auto'
					end

					# enable particular repositories
					if vm_repos.is_a?(Array)
						vm_repos.each do |j|
							# if you start the repo name with a #
							# then it will be disabled... this is
							# useful to kill repos from a poolid.
							if j.start_with? '#'
								vm.vm.provision 'shell', inline: "subscription-manager repos --disable=#{j}"
							else
								vm.vm.provision 'shell', inline: "subscription-manager repos --enable=#{j}"
							end
						end

					elsif vm_repos
						# this enables all repositories
						# NOTE: probably a strong edge
						vm.vm.provision 'shell', inline: "for i in `subscription-manager repos --list | grep '^Repo ID:' | awk '{print $3}'`; do subscription-manager repos --enable=$i; done"
					end
				end
			end

			# ensure the $namespace module is present for provisioning...
			if (puppet and vm_puppet and h == 'puppet') and (provision.is_a?(TrueClass) or (provision.is_a?(Array) and provision.include?('puppet')))
				cwd = `pwd`
				mod = File.join(projectdir, 'puppet', 'modules')
				#`cd #{mod} && make MODULENAME=#{namespace} #{namespace} &> /dev/null; cd #{cwd}`
			end

			#
			#	docker (in vm)
			#
			# TODO: do we need to start the docker daemon first ?
			# FIXME: we can't do the importing of the images at the
			# vm build time because we can't get the daemon to run!
			if vm_docker.is_a?(Array)
				vm_docker.each do |j|
					# if there is a docker image already present, use that
					# otherwise pull one down...
					vm.vm.provision 'shell', inline: "if [ -e '/root/docker/#{j[:name]}.docker' ]; then docker load --input='/root/docker/#{j[:name]}.docker'; else docker pull '#{j[:name]}'; fi"
				end

			elsif vm_docker
				# pull in all the docker images that the vm has
				vm.vm.provision 'shell', inline: 'for i in /root/docker/*.docker; do [ -e "$i" ] || continue; docker load --input="$i"; done'
			end

			# TODO: should we run the docker pull with vagrant too?
			if vm_docker.is_a?(Array)
				vm.vm.provision :docker, images: vm_docker.map { |y| y.fetch(:name, nil)}.compact
			end

			if vm_docker.is_a?(Array)
				vm_docker.each do |y|
					vm.vm.provision :docker do |d|
						# XXX y is now a hash to be used here...
					end
				end

			elsif vm_docker
				vm.vm.provision :docker do |d|
					# XXX
					#d.build_image '/vagrant/app'	# XXX: add a synced folder...
					#d.run 'foo'	XXX
				end
			end

			#
			#	puppet agent - run on puppet client to set it up
			#
			if puppet and vm_puppet and h != 'puppet'
				vm.vm.provision :puppet_server do |p|
					#p.puppet_node = "#{h}"	# redundant
					#p.puppet_server = "puppet.#{domain}"
					p.puppet_server = 'puppet'
					#p.options = '--verbose --debug'
					p.options = '--test'	# see the output
					p.facter = {
						'vagrant' => '1',
						'vagrant_vip' => vip_ip,
						'vagrant_vip_fqdn' => "#{vip_hostname}.#{domain}",
					}
				end

			#
			#	puppet apply - run on puppet master to set it up
			#
			elsif puppet and vm_puppet and h == 'puppet'
				vm.vm.provision :puppet do |p|
					p.module_path = 'puppet/modules'
					p.manifests_path = 'puppet/manifests'
					p.manifest_file = 'site.pp'
					# custom fact
					p.facter = {
						'vagrant' => '1',
						'vagrant_allow' => (1..vms.length).map{|z| range[offset+z].to_s}.join(','),
					}
					p.synced_folder_type = sync
				end
			end

			vm.vm.provider :libvirt do |libvirt|
				# add additional disks to the os
				#(1..disks).each do |j|	# if disks is 0, this passes :)
				#	#print "disk: #{j}"
				#	libvirt.storage :file,
				#		#:path => '',		# auto!
				#		#:device => 'vdb',	# auto!
				#		#:size => '10G',	# auto!
				#		:type => 'qcow2'
				#
				#end

				# make puppet server a bit fatter by default :P
				if puppet and vm_puppet and h == 'puppet'
					libvirt.cpus = 2
					libvirt.memory = 1024
				end
			end
		end
	end

	#
	#	libvirt
	#
	config.vm.provider :libvirt do |libvirt|
		libvirt.driver = 'kvm'	# needed for kvm performance benefits !
		# leave out to connect directly with qemu:///system
		#libvirt.host = 'localhost'
		libvirt.connect_via_ssh = false
		libvirt.username = 'root'
		libvirt.storage_pool_name = 'default'
		#libvirt.default_network = 'default'	# XXX: this does nothing
		libvirt.default_prefix = "#{namespace}"	# set a prefix for your vm's...
	end

end

