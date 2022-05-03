require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

shared_context 'jenkins' do
  # rspec examples are not available as variables to serverspec describe blocks
  SYSCONFDIR = case fact 'osfamily'
               when 'RedHat'
                 '/etc/sysconfig'
               when 'Debian'
                 '/etc/default'
               when 'Archlinux'
                 '/etc/conf.d'
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
