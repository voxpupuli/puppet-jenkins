require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'winrm'

# Install Puppet
unless ENV['RS_PROVISION'] == 'no'
hosts.each do |host|
  case host['platform']
    when /windows/
      include Serverspec::Helper::Windows
      include Serverspec::Helper::WinRM
    end
  end
  
  ENV['PUPPET_INSTALL_TYPE'] ||= 'agent'
  # puppet_install_helper does not understand pessimistic version constraints
  # so we are ignoring PUPPET_VERSION.  Use PUPPET_INSTALL_VERSION instead.
  ENV.delete 'PUPPET_VERSION'
  run_puppet_install_helper
end

UNSUPPORTED_PLATFORMS = ['Suse','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
	if host['platform'] =~ /windows/
      endpoint = "http://127.0.0.1:5985/wsman"
      c.winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => 'vagrant', :pass => 'vagrant', :basic_auth_only => true)
      c.winrm.set_timeout 300
    end
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
			 when 'Windows'
			  'C:/ProgramFiles (x86)/Jenkins'
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