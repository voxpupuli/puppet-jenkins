require 'spec_helper'
require 'json'

describe Puppet::Type.type(:jenkins_authorization_strategy).provider(:cli) do
  let(:strategy_oauth_json) do
    <<-EOS
      {
          "setAuthorizationStrategy": {
              "org.jenkinsci.plugins.GithubAuthorizationStrategy": [
                  "jhoblitt, dne",
                  false,
                  false,
                  false,
                  "lsst, sqre-test",
                  false,
                  false,
                  false
              ]
          }
      }
    EOS
  end
  let(:strategy_oauth) { JSON.parse(strategy_oauth_json) }

  let(:strategy_unsecured_json) do
    <<-EOS
      {
          "setAuthorizationStrategy": {
              "hudson.security.AuthorizationStrategy$Unsecured": [

              ]
          }
      }
    EOS
  end
  let(:strategy_unsecured) { JSON.parse(strategy_unsecured_json) }

  shared_examples 'a provider from example strategy' do
    it do
      method_name = 'setAuthorizationStrategy'
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
        expect(described_class).to receive(:get_authorization_strategy).
          with(nil) { strategy_oauth }
      end

      it 'should return the correct number of instances' do
        expect(described_class.instances.size).to eq 1
      end

      context 'first instance returned' do
        it_behaves_like 'a provider from example strategy' do
          let(:info) { strategy_oauth }
          let(:provider) { described_class.instances[0] }
        end
      end
    end

    context 'when called with a catalog param' do
      it 'should pass it on ::get_authorization_strategy' do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:get_authorization_strategy).
          with(catalog) { strategy_oauth }

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

    it 'should call set_strategy_unsecured' do
      provider = described_class.new
      provider.destroy

      expect(provider).to receive(:set_strategy_unsecured)
      provider.flush
    end

    it 'should call set_strategy_unsecured' do
      provider = described_class.new

      expect(provider).to receive(:set_strategy_unsecured)
      provider.flush
    end
  end # #flush

  #
  # private methods
  #

  describe '::from_hash' do
    it_behaves_like 'a provider from example strategy' do
      let(:info) { strategy_oauth }
      let(:provider) { described_class.send(:from_hash, info) }
    end

    it_behaves_like 'a provider from example strategy' do
      let(:info) { strategy_unsecured }
      let(:provider) { described_class.send(:from_hash, info) }
    end
  end # ::from_hash

  describe '::to_hash' do
    # not isolated from ::from_hash in the interests of staying DRY
    it do
      provider = described_class.send :from_hash, strategy_oauth
      info = provider.send :to_hash

      expect(info).to eq strategy_oauth
    end
  end # ::to_hash

  describe '::get_authorization_strategy' do
    it do
      expect(described_class).to receive(:clihelper).with(
        ['get_authorization_strategy'],
        {:catalog => nil},
      ) { strategy_oauth_json }

      raw = described_class.send :get_authorization_strategy
      expect(raw).to eq strategy_oauth
    end
  end # ::get_authorization_strategy

  describe '#set_jenkins_instance' do
    it do
      provider = described_class.send :from_hash, strategy_oauth

      expect(described_class).to receive(:clihelper).with(
        ['set_jenkins_instance'],
        { :stdinjson => strategy_oauth },
      )

      provider.send :set_jenkins_instance
    end
  end # #set_jenkins_instance

  describe '#set_strategy_unsecured' do
    it do
      provider = described_class.new(:name => 'test')

      expect(described_class).to receive(:clihelper).with(
        ['set_jenkins_instance'],
        { :stdinjson => strategy_unsecured },
      )

      provider.send :set_strategy_unsecured
    end
  end # #set_security_none
end
