require 'rubygems'
require 'rspec'
require 'puppetlabs_spec_helper/module_spec_helper'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))

RSpec.configure do |c|
  # Override puppetlabs_spec_helper's stupid setting of mock_with to :mocha,
  # which is a totally piece of garbage mocking library
  c.mock_with :rspec

  def clear_facts
    Facter.clear
    Facter.clear_messages
  end

  c.before(:each, :type => :fact) do
    # Need to make sure we clear out our facts at the start to make sure that
    # we don't pick up some facts left over from rspec-puppet
    clear_facts
  end
  c.after(:each, :type => :fact) do
    clear_facts
  end

  c.before :each do
    if self.respond_to? :pre_condition
      if pre_condition.instance_of? Array
        pre_condition << 'class stdlib {}'
      else
        pre_condition = "class stdlib {} \n #{pre_condition}"
      end
    end
  end
end
