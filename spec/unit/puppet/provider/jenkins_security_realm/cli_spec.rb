require 'spec_helper'
require 'json'

describe Puppet::Type.type(:jenkins_security_realm).provider(:cli) do
  let(:realm_oauth_json) do
    <<-EOS
      {
          "setSecurityRealm": {
              "org.jenkinsci.plugins.GithubSecurityRealm": [
                  "https://github.com",
                  "https://api.github.com",
                  "42",
                  "43",
                  "read:org"
              ]
          }
      }
    EOS
  end
  let(:realm_oauth) { JSON.parse(realm_oauth_json) }

  let(:realm_none_json) do
    <<-EOS
      {
          "setSecurityRealm": {
              "hudson.security.SecurityRealm$None": [

              ]
          }
      }
    EOS
  end
  let(:realm_none) { JSON.parse(realm_none_json) }

  shared_examples 'a provider from example realm' do
    it do
      method_name = 'setSecurityRealm'
      class_name = info[method_name].keys.first
      ctor_args = info[method_name][class_name]

      expect(provider.name).to eq class_name
      expect(provider.ensure).to eq :present
      expect(provider.arguments).to eq ctor_args
    end
  end

  describe '::instances' do
    context 'without any params' do
      before do
        expect(described_class).to receive(:get_security_realm).
          with(nil) { realm_oauth }
      end

      it 'should return the correct number of instances' do
        expect(described_class.instances.size).to eq 1
      end

      context 'first instance returned' do
        it_behaves_like 'a provider from example realm' do
          let(:info) { realm_oauth }
          let(:provider) { described_class.instances[0] }
        end
      end
    end

    context 'when called with a catalog param' do
      it 'should pass it on ::get_security_realm' do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:get_security_realm).
          with(catalog) { realm_oauth }

        described_class.instances(catalog)
      end
    end
  end # ::instanes

  describe '#flush' do
    it 'should call set_jenkins_instance' do
      provider = described_class.new
      provider.create

      expect(provider).to receive(:set_jenkins_instance)
      provider.flush
    end

    it 'should call set_security_none' do
      provider = described_class.new
      provider.destroy

      expect(provider).to receive(:set_security_none)
      provider.flush
    end

    it 'should call set_security_none' do
      provider = described_class.new

      expect(provider).to receive(:set_security_none)
      provider.flush
    end
  end # #flush

  #
  # private methods
  #

  describe '::from_hash' do
    it_behaves_like 'a provider from example realm' do
      let(:info) { realm_oauth }
      let(:provider) { described_class.send(:from_hash, info) }
    end

    it_behaves_like 'a provider from example realm' do
      let(:info) { realm_none }
      let(:provider) { described_class.send(:from_hash, info) }
    end
  end # ::from_hash

  describe '::to_hash' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      provider = described_class.send :from_hash, realm_oauth
      info = provider.send :to_hash

      expect(info).to eq realm_oauth
    end
  end # ::to_hash

  describe '::get_security_realm' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      expect(described_class).to receive(:clihelper).with(
        ['get_security_realm'],
        {:catalog => nil}
      ) { realm_oauth_json }

      raw = described_class.send :get_security_realm
      expect(raw).to eq realm_oauth
    end
  end # ::get_security_realm

  describe '#set_jenkins_instance' do
    it do
      provider = described_class.send :from_hash, realm_oauth

      expect(described_class).to receive(:clihelper).with(
        ['set_jenkins_instance'],
        { :stdinjson => realm_oauth },
      )

      provider.send :set_jenkins_instance
    end
  end # #set_jenkins_instance

  describe '#set_security_none' do
    it do
      provider = described_class.new(:name => 'test')

      expect(described_class).to receive(:clihelper).with(
        ['set_jenkins_instance'],
        { :stdinjson => realm_none },
      )

      provider.send :set_security_none
    end
  end # #set_security_none
end
