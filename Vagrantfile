# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define 'develop', primary: true do |dev|
    dev.vm.provider 'virtualbox' do |machine|
      machine.memory = 512
      machine.cpus   = 1
    end

    dev.vm.network 'forwarded_port', guest: 8094, host: 8094
    dev.vm.network 'private_network', ip: '192.168.33.94'

    dev.vm.box             = 'ubuntu/trusty64'
    dev.vm.hostname        = 'sd_full_auto_case'.tr('_', '-')
    dev.vm.post_up_message = <<-POST_UP_MESSAGE
      Machine is up and ready to development. Use `vagrant ssh` to enter.
    POST_UP_MESSAGE
    dev.ssh.forward_agent = true

    dev.vm.provision :shell, keep_color: true, inline: <<-PROVISION
      echo 'StrictHostKeyChecking no' > ~/.ssh/config
      echo 'UserKnownHostsFile=/dev/null no' >> ~/.ssh/config
      sudo apt-get update
      sudo apt-get install git -y
    PROVISION

    dev.vm.provision :ansible_local do |ansible|
      ansible.provisioning_path = '/vagrant/cm/provisioning'
      ansible.playbook          = 'main.yml'
      ansible.inventory_path    = 'inventory.ini'
      ansible.verbose           = true
      ansible.limit             = 'local'
      ansible.galaxy_roles_path = 'roles'
      ansible.galaxy_role_file  = 'requirements.yml'
    end
  end

  config.cache.scope = :box if Vagrant.has_plugin?('vagrant-cachier')
end
