require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:test) {
  newparam(:foo) { isnamevar }
}

describe Puppet::Type.type(:test) do
  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
  end
end
