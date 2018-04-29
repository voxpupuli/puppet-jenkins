require 'rspec'
require 'rspec/its'
require 'puppetlabs_spec_helper/module_spec_helper'

ENV['STRICT_VARIABLES'] = 'no'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/fixtures/modules/archive/lib'))
require 'spec/helpers/rspechelpers'

RSpec.configure do |c|
  c.mock_with :rspec
  c.include(Jenkins::RSpecHelpers)
  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }
  default_facts.merge!(YAML.load(File.read(File.expand_path('../default_facts.yml', __FILE__)))) if File.exist?(File.expand_path('../default_facts.yml', __FILE__))
  default_facts.merge!(YAML.load(File.read(File.expand_path('../default_module_facts.yml', __FILE__)))) if File.exist?(File.expand_path('../default_module_facts.yml', __FILE__))
  c.default_facts = default_facts
end

# a simple class to inject :undef
# https://groups.google.com/d/msg/puppet-users/6nL2eROH8is/UDqRNu34lB0J
class Undef
  def inspect
    'undef'
  end
end
