require_relative '../spec_helper'

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
