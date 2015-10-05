require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_num_executors) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable', :present
    end
  end # properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'
  end
end
