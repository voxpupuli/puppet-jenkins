require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_credentials) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable'
    end

    describe 'domain' do
      it_behaves_like 'validated property', :domain, :undef, [:undef]
    end

    describe 'scope' do
      it_behaves_like 'validated property', :scope, :GLOBAL, [:GLOBAL, :SYSTEM]
    end

    describe 'impl' do
      it_behaves_like 'validated property', :impl,
        :UsernamePasswordCredentialsImpl,
        [
          :UsernamePasswordCredentialsImpl,
          :BasicSSHUserPrivateKey,
          :StringCredentialsImpl,
        ]
    end

    # unvalidated properties
    [
      :description,
      :username,
      :password,
      :private_key,
      :passphrase,
      :secret,
      :file_name,
      :content,
      :source,
      :key_store_impl
    ].each do |property|
      describe "#{property}" do
        context 'attrtype' do
          it { expect(described_class.attrtype(property)).to eq :property }
        end
      end
    end
  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'
  end
end
