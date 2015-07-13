require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

# Install Puppet
unless ENV['RS_PROVISION'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    on host, "mkdir -p #{host['distmoduledir']}"
  end
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
      shell("/bin/touch #{default['puppetpath']}/hiera.yaml")

      on host, puppet('module install puppetlabs-stdlib'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppetlabs-java'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppetlabs-apt'), { :acceptable_exit_codes => [0] }

      on host, puppet('module install darin-zypprepo'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install camptocamp-archive'), { :acceptable_exit_codes => [0] }
    end
  end
end
