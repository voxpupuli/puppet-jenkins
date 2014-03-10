require 'rubygems'
require 'rspec'
require 'puppetlabs_spec_helper/module_spec_helper'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))

RSpec.configure do |c|
  # Override puppetlabs_spec_helper's stupid setting of mock_with to :mocha,
  # which is a totally piece of garbage mocking library
  c.mock_with :rspec

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
