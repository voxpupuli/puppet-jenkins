require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

# Install Puppet
unless ENV['RS_PROVISION'] == 'no'
  ENV['PUPPET_INSTALL_TYPE'] ||= 'agent'
  # puppet_install_helper does not understand pessimistic version constraints
  # so we are ignoring PUPPET_VERSION.  Use PUPPET_INSTALL_VERSION instead.
  ENV.delete 'PUPPET_VERSION'
  run_puppet_install_helper
end

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'jenkins')

      on host, puppet('module install puppetlabs-stdlib'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppetlabs-java'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppetlabs-apt'), { :acceptable_exit_codes => [0] }

      on host, puppet('module install darin-zypprepo'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppet-archive'), { :acceptable_exit_codes => [0] }
    end
  end
end

shared_context 'jenkins' do
  # rspec examples are not avaiable as variables to serverspec describe blocks
  $libdir = case fact 'osfamily'
            when 'RedHat'
              '/usr/lib/jenkins'
            when 'Debian'
              '/usr/share/jenkins'
            end

  let(:libdir) { $libdir }

  let(:base_manifest) do
    <<-EOS
      include ::jenkins

      class { '::jenkins::cli::config':
        cli_jar       => '#{libdir}/jenkins-cli.jar',
        puppet_helper => '#{libdir}/puppet_helper.groovy',
      }
    EOS
  end
end
