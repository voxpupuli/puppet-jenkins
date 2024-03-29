# frozen_string_literal: true

require 'spec_helper'
require 'unit/puppet/x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_credentials) do
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

    describe 'domain' do
      it_behaves_like 'validated property', :domain, :undef, [:undef]
    end

    describe 'scope' do
      it_behaves_like 'validated property', :scope, :GLOBAL, %i[GLOBAL SYSTEM]
    end

    describe 'impl' do
      it_behaves_like 'validated property', :impl,
                      :UsernamePasswordCredentialsImpl,
                      %i[
                        UsernamePasswordCredentialsImpl
                        BasicSSHUserPrivateKey
                        StringCredentialsImpl
                        FileCredentialsImpl
                        AWSCredentialsImpl
                        GitLabApiTokenImpl
                        BrowserStackCredentials
                      ]
    end

    # unvalidated properties
    %i[
      description
      username
      password
      private_key
      passphrase
      secret
      file_name
      content
      source
      key_store_impl
      secret_key
      access_key
      api_token
    ].each do |property|
      describe property.to_s do
        context 'attrtype' do
          it { expect(described_class.attrtype(property)).to eq :property }
        end
      end
    end
  end

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'
  end
end
