require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

UNSUPPORTED_PLATFORMS = %w[Suse windows AIX Solaris].freeze

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    install_module_on(hosts)
    install_module_dependencies_on(hosts)
  end
end

shared_context 'jenkins' do
  # rspec examples are not avaiable as variables to serverspec describe blocks
  $libdir = case fact 'osfamily'
            when 'RedHat'
              '/usr/lib/jenkins'
            when 'Debian'
              '/usr/share/jenkins'
            when 'Archlinux'
              '/usr/share/java/jenkins/'
            end
  $sysconfdir = case fact 'osfamily'
                when 'RedHat'
                  '/etc/sysconfig'
                when 'Debian'
                  '/etc/default'
                when 'Archlinux'
                  '/etc/conf.d'
                end

  let(:libdir) { $libdir }

  let(:base_manifest) do
    <<-EOS
      class { '::jenkins':
        cli_remoting_free => true,
      }

      class { '::jenkins::cli::config':
        cli_jar           => '#{libdir}/jenkins-cli.jar',
        puppet_helper     => '#{libdir}/puppet_helper.groovy',
        cli_remoting_free => true,
      }
    EOS
  end
end

def apply(pp, options = {})
  options[:debug] = true if ENV.key?('PUPPET_DEBUG')

  apply_manifest(pp, options)
end

# Run it twice and test for idempotency
def apply2(pp)
  apply(pp, catch_failures: true)
  apply(pp, catch_changes: true)
end

# probe stolen from:
# https://github.com/camptocamp/puppet-systemd/blob/master/lib/facter/systemd.rb#L26
#
# See these issues for an explination of why this is nessicary rather than
# using fact() from beaker-facter in the DSL:
#
# https://tickets.puppetlabs.com/browse/BKR-1040
# https://tickets.puppetlabs.com/browse/BKR-1041
#
$systemd = if shell('ps -p 1 -o comm=').stdout =~ %r{systemd}
             true
           else
             false
           end
