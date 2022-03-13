# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

shared_context 'jenkins' do
  # rspec examples are not available as variables to serverspec describe blocks
  # rubocop:todo RSpec/LeakyConstantDeclaration
  # rubocop:todo Style/HashLikeCase
  LIBDIR = case fact 'osfamily' # rubocop:todo Lint/ConstantDefinitionInBlock, Style/HashLikeCase, RSpec/LeakyConstantDeclaration
           when 'RedHat'
             '/usr/lib/jenkins'
           when 'Debian'
             '/usr/share/jenkins'
           when 'Archlinux'
             '/usr/share/java/jenkins/'
           end
  # rubocop:enable Style/HashLikeCase
  # rubocop:enable RSpec/LeakyConstantDeclaration
  # rubocop:todo RSpec/LeakyConstantDeclaration
  # rubocop:todo Style/HashLikeCase
  SYSCONFDIR = case fact 'osfamily' # rubocop:todo Lint/ConstantDefinitionInBlock, Style/HashLikeCase, RSpec/LeakyConstantDeclaration
               when 'RedHat'
                 '/etc/sysconfig'
               when 'Debian'
                 '/etc/default'
               when 'Archlinux'
                 '/etc/conf.d'
               end
  # rubocop:enable Style/HashLikeCase
  # rubocop:enable RSpec/LeakyConstantDeclaration

  let(:libdir) { LIBDIR }

  let(:base_manifest) do
    <<-EOS
      include jenkins
      class { 'jenkins::cli::config':
        cli_jar       => '#{libdir}/jenkins-cli.jar',
        puppet_helper => '#{libdir}/puppet_helper.groovy',
      }
    EOS
  end
end

def apply(pp, options = {})
  options[:debug] = true if ENV.key?('PUPPET_DEBUG')

  apply_manifest(pp, options)
end

# Run it twice and test for idempotency
# And know value of custom fact during acceptance tests
def apply2(pp)
  it 'works with no error' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'gets custom fact on first run' do
    on(hosts, 'facter --json jenkins_plugins')
  end

  it 'works idempotently' do
    apply_manifest(pp, catch_changes: true)
  end

  it 'gets custom fact on second run' do
    on(hosts, 'facter --json jenkins_plugins')
  end
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
SYSTEMD = shell('ps -p 1 -o comm=').stdout =~ %r{systemd}
