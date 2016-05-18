require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_providers'

require 'json'

describe Puppet::Type.type(:jenkins_user).provider(:cli) do
  let(:user_info_json) do
    <<-EOS
      [
        {

          "id": "test",
          "full_name": "test",
          "email_address": "foo@foo.org",
          "public_keys": ["ssh-rsa foo com", "ssh-rsa bar com"],
          "api_token_public": "b0da1e0bf3f79ff02624c2f716913808",
          "api_token_plain": "51a8b1dd95bc76b1a2869356c043e8b9",
          "password": "#jbcrypt:$2a$10$dg5kqB/bNVgotE0alN.V5OQJ1BajkmM2ZOFAmtlSt29bB4xEDZOja"
        },
        {
          "id": "guest"
        }
      ]
    EOS
  end
  let(:user_info) { JSON.parse(user_info_json) }
  let(:mutable_user_info) do
    # we should not be trying to flush the api_token_public value as it is
    # immutable
    info = user_info[0]
    info.delete('api_token_public')
    info
  end

  shared_examples 'a provider from example hash 1' do
    it do
      expect(provider.name).to eq user_info[0]['id']
      expect(provider.ensure).to eq :present
      expect(provider.full_name).to eq user_info[0]['full_name']
      expect(provider.email_address).to eq user_info[0]['email_address']
      expect(provider.public_keys).to eq user_info[0]['public_keys']
      expect(provider.api_token_public).to eq user_info[0]['api_token_public']
      expect(provider.api_token_plain).to eq user_info[0]['api_token_plain']
      expect(provider.password).to eq user_info[0]['password']
    end
  end

  shared_examples 'a provider from example hash 2' do
    it do
      expect(provider.name).to eq user_info[1]['id']
      expect(provider.ensure).to eq :present
      expect(provider.full_name).to eq :absent
      expect(provider.email_address).to eq :absent
      expect(provider.public_keys).to eq :absent
      expect(provider.api_token_public).to eq :absent
      expect(provider.api_token_plain).to eq :absent
      expect(provider.password).to eq :absent
    end
  end

  include_examples 'confines to cli dependencies'

  describe '::instances' do
    context 'without any params' do
      before do
        expect(described_class).to receive(:user_info_all).
          with(nil) { user_info }
      end

      it 'should return the correct number of instances' do
        expect(described_class.instances.size).to eq 2
      end

      context 'first instance returned' do
        it_behaves_like 'a provider from example hash 1' do
          let(:provider) do
            described_class.instances[0]
          end
        end
      end

      context 'second instance returned' do
        it_behaves_like 'a provider from example hash 2' do
          let(:provider) do
            described_class.instances[1]
          end
        end
      end
    end

    context 'when called with a catalog param' do
      it 'should pass it on ::user_info_all' do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:user_info_all).
          with(catalog) { user_info }

        described_class.instances(catalog)
      end
    end
  end # ::instanes

  describe '#api_token_public=' do
    it 'should be read only (fail)' do
      provider = described_class.new

      expect { provider.api_token_public = 'foo' }.to raise_error(Puppet::Error, /api_token_pubilc is read-only/)
    end
  end # #api_token_public=

  describe '#flush' do
    it 'should call user_update' do
      provider = described_class.new
      provider.create

      expect(provider).to receive(:user_update)
      provider.flush
    end

    it 'should call delete_user' do
      provider = described_class.new
      provider.destroy

      expect(provider).to receive(:delete_user)
      provider.flush
    end

    it 'should call delete_user' do
      provider = described_class.new

      expect(provider).to receive(:delete_user)
      provider.flush
    end
  end # #flush

  #
  # private methods
  #

  describe '::from_hash' do
    it_behaves_like 'a provider from example hash 1' do
      let(:provider) do
        described_class.send :from_hash, user_info[0]
      end
    end

    it_behaves_like 'a provider from example hash 2' do
      let(:provider) do
        described_class.send :from_hash, user_info[1]
      end
    end
  end # ::from_hash

  describe '::to_hash' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      provider = described_class.send :from_hash, user_info[0]
      info = provider.send :to_hash

      expect(info).to eq mutable_user_info
    end
  end # ::to_hash

  describe '::user_info_all' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      expect(described_class).to receive(:clihelper).with(['user_info_all']) { user_info_json }

      raw = described_class.send :user_info_all
      expect(raw).to eq user_info
    end
  end # ::user_info_all

  describe '#user_update' do
    RSpec::Matchers.define :a_json_doc do |x|
      match { |actual| JSON.parse(actual) == x }
    end

    it do
      provider = described_class.send :from_hash, user_info[0]

      expect(described_class).to receive(:clihelper).with(
        ['user_update'],
        { :stdinjson => mutable_user_info },
      )

      provider.send :user_update
    end
  end # #user_update

  describe '#delete_user' do
    it do
      provider = described_class.send :from_hash, user_info[0]

      expect(described_class).to receive(:clihelper).with(
        ['delete_user', 'test']
      )

      provider.send :delete_user
    end
  end # #delete_update
end
