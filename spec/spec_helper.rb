require 'rubygems'
require 'rspec'
require 'puppetlabs_spec_helper/module_spec_helper'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'spec/helpers/rspechelpers'

###########################################################################
# Required for :type => :serverspec
require 'serverspec'
require 'pathname'
require 'net/ssh'
# Need to upll these into the global scope before we evaluate all our RSpec
# files :(
include  SpecInfra::Helper::Ssh
include  SpecInfra::Helper::DetectOS
###########################################################################

RSpec.configure do |c|
  # Override puppetlabs_spec_helper's stupid setting of mock_with to :mocha,
  # which is a totally piece of garbage mocking library
  c.mock_with :rspec
  c.deprecation_stream = '/dev/null'

  c.include(Jenkins::RSpecHelpers)
end
