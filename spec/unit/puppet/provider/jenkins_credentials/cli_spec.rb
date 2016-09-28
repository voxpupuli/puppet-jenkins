require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_providers'

require 'json'

describe Puppet::Type.type(:jenkins_credentials).provider(:cli) do
  let(:credentials_list_json_raw) do
    <<-EOS
    [
        {
            "id": "9b07d668-a87e-4877-9407-ae05056e32ac",
            "domain": null,
            "scope": "GLOBAL",
            "impl": "UsernamePasswordCredentialsImpl",
            "description": "foo",
            "username": "batman",
            "password": "password"
        },
        {
            "id": "14dbba6e-fc00-4102-ae97-7a178058f91b",
            "domain": null,
            "scope": "SYSTEM",
            "impl": "BasicSSHUserPrivateKey",
            "description": "bar",
            "private_key": "-----BEGIN RSA PRIVATE KEY-----",
            "username": "robin",
            "passphrase": ""
        },
        {
            "id": "150b2895-b0eb-4813-b8a5-3779690c063c",
            "domain": null,
            "scope": "SYSTEM",
            "impl": "StringCredentialsImpl",
            "description": "baz",
            "secret": "fluffy bunny"
        }
    ]
    EOS
  end
  let(:credentials) { JSON.parse(credentials_list_json_raw) }

  shared_examples 'a provider from example hash 1' do
    it do
      cred = credentials[0]

      expect(provider.name).to eq cred['id']
      expect(provider.ensure).to eq :present
      [
        'domain',
        'scope',
        'impl',
        'description',
        'username',
        'password',
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq cred[k].nil? ? :undef : cred[k]
      end

      [
        'private_key',
        'passphrase',
        'secret',
        'file_name',
        'content',
        'source',
        'key_store_impl'
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq :absent
      end
    end
  end

  shared_examples 'a provider from example hash 2' do
    it do
      cred = credentials[1]

      expect(provider.name).to eq cred['id']
      expect(provider.ensure).to eq :present
      [
        'domain',
        'scope',
        'impl',
        'description',
        'username',
        'private_key',
        'passphrase',
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq cred[k].nil? ? :undef : cred[k]
      end

      [
        'password',
        'secret',
        'file_name',
        'content',
        'source',
        'key_store_impl'
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq :absent
      end

    end
  end

  shared_examples 'a provider from example hash 3' do
    it do
      cred = credentials[2]

      expect(provider.name).to eq cred['id']
      expect(provider.ensure).to eq :present
      [
        'domain',
        'scope',
        'impl',
        'description',
        'secret',
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq cred[k].nil? ? :undef : cred[k]
      end

      [
        'username',
        'password',
        'private_key',
        'passphrase',
        'file_name',
        'content',
        'source',
        'key_store_impl'
      ].each do |k|
        expect(provider.public_send(k.to_sym)).to eq :absent
      end

    end
  end

  include_examples 'confines to cli dependencies'

  describe '::instances' do
    context 'without any params' do
      before do
        expect(described_class).to receive(:credentials_list_json).
          with(nil) { credentials }
      end

      it 'should return the correct number of instances' do
        expect(described_class.instances.size).to eq 3
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

      context 'third instance returned' do
        it_behaves_like 'a provider from example hash 3' do
          let(:provider) do
            described_class.instances[2]
          end
        end
      end
    end

    context 'when called with a catalog param' do
      it 'should pass it on ::credentials_list_json' do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:credentials_list_json).
          with(kind_of(Puppet::Resource::Catalog)) { credentials }

        described_class.instances(catalog)
      end
    end
  end # ::instanes

  describe '#flush' do
    it 'should call credentials_update' do
      provider = described_class.new
      provider.create

      expect(provider).to receive(:credentials_update_json)
      provider.flush
    end

    it 'should call credentials_delete_id' do
      provider = described_class.new
      provider.destroy

      expect(provider).to receive(:credentials_delete_id)
      provider.flush
    end

    it 'should call credentials_delete_id' do
      provider = described_class.new

      expect(provider).to receive(:credentials_delete_id)
      provider.flush
    end
  end # #flush

  #
  # private methods
  #

  describe '::from_hash' do
    it_behaves_like 'a provider from example hash 1' do
      let(:provider) do
        described_class.send :from_hash, credentials[0]
      end
    end

    it_behaves_like 'a provider from example hash 2' do
      let(:provider) do
        described_class.send :from_hash, credentials[1]
      end
    end

    it_behaves_like 'a provider from example hash 3' do
      let(:provider) do
        described_class.send :from_hash, credentials[2]
      end
    end
  end # ::from_hash

  describe '::to_hash' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      provider = described_class.send :from_hash, credentials[0]
      info = provider.send :to_hash

      expect(info).to eq credentials[0]
    end
  end # ::to_hash

  describe '::credentials_list_json' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      expect(described_class).to receive(:clihelper).with(
        ['credentials_list_json'],
        {:catalog => nil}
      ) { JSON.pretty_generate(credentials[0]) }

      raw = described_class.send :credentials_list_json
      expect(raw).to eq credentials[0]
    end
  end # ::credentials_list_json

  describe '#credentials_update_json' do
    RSpec::Matchers.define :a_json_doc do |x|
      match { |actual| JSON.parse(actual) == x }
    end

    it do
      provider = described_class.send :from_hash, credentials[0]

      expect(described_class).to receive(:clihelper).with(
        ['credentials_update_json'],
        {:stdinjson => credentials[0]},
      )

      provider.send :credentials_update_json
    end
  end # #credentials_update_json

  describe '#credentials_delete_id' do
    it do
      provider = described_class.send :from_hash, credentials[0]

      expect(described_class).to receive(:clihelper).with(
        ['credentials_delete_id', '9b07d668-a87e-4877-9407-ae05056e32ac']
      )

      provider.send :credentials_delete_id
    end
  end # #credentials_delete_id
end
