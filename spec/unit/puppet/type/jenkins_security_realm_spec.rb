# frozen_string_literal: true

require 'spec_helper'
require 'unit/puppet/x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_security_realm) do
  before { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end
  end

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable'
    end

    describe 'arguments' do
      it_behaves_like 'array_matching property'
    end
  end

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
  end
end
