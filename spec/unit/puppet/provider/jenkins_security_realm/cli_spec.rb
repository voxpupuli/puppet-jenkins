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
        allow(described_class).to receive(:get_security_realm).
          with(nil).and_return(realm_oauth)
      end

      it 'returns the correct number of instances' do
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
      it 'passes it on ::get_security_realm' do
        catalog = Puppet::Resource::Catalog.new

        allow(described_class).to receive(:get_security_realm).
          with(catalog).and_return(realm_oauth)

        described_class.instances(catalog)

        expect(described_class).to have_received(:get_security_realm).
          with(catalog)
      end
    end
  end # ::instanes

  describe '#flush' do
    it 'calls set_jenkins_instance' do
      provider = described_class.new
      provider.create

      allow(provider).to receive(:set_jenkins_instance)
      provider.flush
      expect(provider).to have_received(:set_jenkins_instance)
    end

    it 'calls set_security_none' do
      provider = described_class.new
      provider.destroy

      allow(provider).to receive(:set_security_none)
      provider.flush
      expect(provider).to have_received(:set_security_none)
    end

    it 'calls set_security_none' do
      provider = described_class.new

      allow(provider).to receive(:set_security_none)
      provider.flush
      expect(provider).to have_received(:set_security_none)
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
      allow(described_class).to receive(:clihelper).with(
        ['get_security_realm'],
        catalog: nil
      ).and_return(realm_oauth_json)

      raw = described_class.send :get_security_realm
      expect(raw).to eq realm_oauth
      expect(described_class).to have_received(:clihelper).with(
        ['get_security_realm'],
        catalog: nil
      )
    end
  end # ::get_security_realm

  describe '#set_jenkins_instance' do
    it do
      provider = described_class.send :from_hash, realm_oauth

      allow(described_class).to receive(:clihelper)

      provider.send :set_jenkins_instance

      expect(described_class).to have_received(:clihelper).with(
        ['set_jenkins_instance'],
        stdinjson: realm_oauth
      )
    end
  end # #set_jenkins_instance

  describe '#set_security_none' do
    it do
      provider = described_class.new(name: 'test')

      allow(described_class).to receive(:clihelper)

      provider.send :set_security_none

      expect(described_class).to have_received(:clihelper).with(
        ['set_jenkins_instance'],
        stdinjson: realm_none
      )
    end
  end # #set_security_none
end
