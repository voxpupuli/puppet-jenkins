require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_user) do
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

    # unvalidated properties
    [:full_name, :email_address,
     :api_token_public, :password].each do |property|
      describe "#{property}" do
        it { expect(described_class.attrtype(property)).to eq :property }
      end
    end

    describe 'api_token_plain' do
      it { expect(described_class.attrtype(:api_token_plain)).to eq :property }

      it 'should support valid hexstrings' do
        value = '51a8b1dd95bc76b1a2869356c043e8b9'
        expect {
          described_class.new(
            :name => 'nobody',
            :api_token_plain => value
          )
        }
          .to_not raise_error
      end

      %w[ 51a8b1dd95bc76b1a2869356c043e8b
          51a8b1dd95bc76b1a2869356c043e8b99 ].each do |value|
        it 'should reject hexstrings of invalid length' do
          expect {
            described_class.new(
              :name => 'nobody',
              :api_token_plain => value,
            )
          }
            .to raise_error(Puppet::ResourceError, /is not a 32char hex string/)
        end
      end
    end #api_token_plain

    describe 'public_keys' do
      it { expect(described_class.attrtype(:public_keys)).to eq :property }

      it 'should support single string' do
        value = 'ssh-rsa blah comment'
        user = described_class.new(:name => 'nobody', :public_keys => value)
        expect(user[:public_keys]).to eq [value]
      end

      it 'should support array of string' do
        value = ['ssh-rsa blah comment', 'ssh-rsa foo comment']
        user = described_class.new(:name => 'nobody', :public_keys => value)
        expect(user[:public_keys]).to eq value
      end
    end #public_keys
  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
  end
end
