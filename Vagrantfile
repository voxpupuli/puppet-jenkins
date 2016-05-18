require 'yaml'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'

Vagrant.configure('2') do |config|
  access_key_id = File.read('.vagrant_key_id').chomp
  secret_access_key = File.read('.vagrant_secret_access_key').chomp
  keypair = File.read('.vagrant_keypair_name').chomp

  config.vm.box = 'dummy'

  Dir['spec/serverspec/*'].each do |dname|
    next unless File.directory?(dname)
    # Convert spec/serverspec/ubuntu-precise into 'ubuntu-precise'
    name = File.basename(dname)
    spec_config = YAML.load_file(File.join(dname + '/config.yml'))

    config.vm.synced_folder '.', '/vagrant/jenkins', type: 'rsync'

    config.vm.define(name) do |node|
      # This is a Vagrant-local hack to make sure we have properly udpated apt
      # caches since AWS machines are definitely going to have stale ones
      node.vm.provision 'shell',
        :inline => 'if [ ! -f "/apt-cached" ]; then apt-get update && touch /apt-cached; fi'
      node.vm.provision 'shell',
        :inline => 'ln -sf /tmp/vagrant-puppet-2/modules-0 /tmp/vagrant-puppet-2/modules-0/jenkins'

      node.vm.provision 'puppet' do |pp|
        pp.module_path = [
          '.',
          'spec/fixtures/modules',
        ]
        pp.manifests_path = "spec/serverspec/#{name}/manifests"
      end


      node.vm.provision :serverspec do |spec|
        spec.pattern = "spec/serverspec/#{name}/*_spec.rb"
      end

      node.vm.provider :aws do |aws, override|
        aws.access_key_id = access_key_id
        aws.secret_access_key = secret_access_key
        aws.keypair_name = keypair

        hostname = "vagrant-jenkins-#{name}"
        # Ensuring that our machines hostname is "correct" so Puppet will apply
        # the right resources to it
        aws.user_data = "#!/bin/sh
  echo '#{hostname}' > /etc/hostname;
  hostname '#{hostname}';"

        aws.tags = {:Name => hostname}

        # Ubuntu LTS 12.04 in us-west-2 with Puppet installed from the Puppet
        # Labs apt repository
        aws.ami = spec_config['ami']
        aws.region = spec_config['region']
        override.ssh.username = spec_config['username']
        override.ssh.private_key_path = File.expand_path('~/.ssh/id_rsa')
      end
    end
  end
end

# vim: ft=ruby
