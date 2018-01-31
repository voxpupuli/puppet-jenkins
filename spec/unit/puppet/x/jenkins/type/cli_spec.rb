require 'spec_helper'
require 'unit/puppet/x/spec_jenkins_types'

require 'puppet/x/jenkins/type/cli'

Puppet::X::Jenkins::Type::Cli.newtype(:test) do
  newparam(:foo) { isnamevar }
end

describe Puppet::Type.type(:test) do
  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
  end
end
