require 'spec_helper'

require 'puppet_x/jenkins/config'

describe PuppetX::Jenkins::Config do
  DEFAULTS = {
    :cli_jar         => '/usr/lib/jenkins/jenkins-cli.jar',
    :url             => 'http://localhost:8080',
    :ssh_private_key => nil,
    :puppet_helper   => '/usr/lib/jenkins/puppet_helper.groovy',
    :cli_tries       => 30,
    :cli_try_sleep   => 2,
  }

  shared_context 'facts' do
    before do
      Facter.add(:jenkins_cli_jar) { setcode { 'fact.jar' } }
      Facter.add(:jenkins_url) { setcode { 'http://localhost:11' } }
      Facter.add(:jenkins_ssh_private_key) { setcode { 'fact.id_rsa' } }
      Facter.add(:jenkins_puppet_helper) { setcode { 'fact.groovy' } }
      Facter.add(:jenkins_cli_tries) { setcode { 22 } }
      Facter.add(:jenkins_cli_try_sleep) { setcode { 33 } }
    end
  end

  shared_examples 'returns default values' do |param|
    it 'should return default values' do
      DEFAULTS.each do |k, v|
        expect(config[k]).to eq v
      end
    end
  end # returns default values

  shared_examples 'returns fact values' do |param|
    it 'should return fact values' do
      DEFAULTS.each do |k, v|
        expect(config[k]).to eq Facter.value("jenkins_#{k.to_s}".to_sym)
      end
    end
  end # returns fact values

  shared_examples 'returns catalog values' do |param|
    it 'should return catalog values' do
      config = catalog.resource(:class, 'jenkins::cli::config')

      DEFAULTS.each do |k, v|
        expect(config[k]).to eq config[k]
      end
    end
  end # returns catalog values

  before(:each) { Facter.clear }

  # we are relying on a side effect of this method being to test features /
  # load libs
  describe '#initialize' do
    it { expect(described_class.new).to be_kind_of PuppetX::Jenkins::Config }
  end

  describe '#[]' do
    context 'unknown config key' do
      it do
        expect{described_class.new[:foo]}
          .to raise_error(PuppetX::Jenkins::Config::UnknownConfig)
      end
    end # unknown config key

    context 'no catalog' do
      let(:config) { described_class.new }

      context 'no facts' do
        include_examples 'returns default values'
      end # no facts

      context 'with facts' do
        include_examples 'returns fact values' do
          include_context 'facts'
        end
      end # with facts
    end # no catalog

    context 'with catalog' do
      let(:catalog) { Puppet::Resource::Catalog.new }
      let(:config) { described_class.new(catalog) }

      context 'no jenkins::cli::config class' do
        context 'no facts' do
          include_examples 'returns default values'
        end # no facts

        context 'with facts' do
          include_examples 'returns fact values' do
            include_context 'facts'
          end
        end # with facts
      end # no jenkins::cli::config class

      context 'with jenkins::cli::config class' do
        context 'with no params' do
          before do
            jenkins = Puppet::Type.type(:component).new(
              :name => 'jenkins::cli::config',
            )

            catalog.add_resource jenkins
          end

          context 'no facts' do
            include_examples 'returns default values'
          end # no facts

          context 'with facts' do
            include_examples 'returns fact values' do
              include_context 'facts'
            end
          end # with facts
        end # with no params

        context 'with all params' do
          before do
            jenkins = Puppet::Type.type(:component).new(
              :name            => 'jenkins::cli::config',
              :cli_jar         => 'cat.jar',
              :url             => 'http://localhost:111',
              :ssh_private_key => 'cat.id_rsa',
              :puppet_helper   => 'cat.groovy',
              :cli_tries       => 222,
              :cli_try_sleep   => 333,
            )

            catalog.add_resource jenkins
          end

          context 'no facts' do
            include_examples 'returns catalog values'
          end # no facts

          context 'with facts' do
            include_examples 'returns catalog values' do
              include_context 'facts'
            end
          end # with facts
        end # with all params
      end # no jenkins::cli::config class
    end # with catalog
  end # #[]
end
