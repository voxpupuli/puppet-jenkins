# frozen_string_literal: true

require 'spec_helper'

require 'puppet/x/jenkins/config'

describe Puppet::X::Jenkins::Config do
  DEFAULTS = {
    cli_jar: '/usr/share/java/jenkins-cli.jar',
    url: 'http://localhost:8080',
    ssh_private_key: nil,
    puppet_helper: '/usr/share/java/puppet_helper.groovy',
    cli_tries: 30
  }.freeze

  shared_context 'facts' do
    before do
      Facter.add(:jenkins_cli_jar) { setcode { 'fact.jar' } }
      Facter.add(:jenkins_url) { setcode { 'http://localhost:11' } }
      Facter.add(:jenkins_ssh_private_key) { setcode { 'fact.id_rsa' } }
      Facter.add(:jenkins_puppet_helper) { setcode { 'fact.groovy' } }
      Facter.add(:jenkins_cli_tries) { setcode { 22 } }
    end
  end

  shared_examples 'returns default values' do |_param|
    it 'returns default values' do
      DEFAULTS.each do |k, v|
        expect(config[k]).to eq v
      end
    end
  end

  shared_examples 'returns fact values' do |_param|
    it 'returns fact values' do
      DEFAULTS.each_key do |k|
        expect(config[k]).to eq Facter.value("jenkins_#{k}".to_sym)
      end
    end
  end

  shared_examples 'returns catalog values' do |_param|
    it 'returns catalog values' do
      config = catalog.resource(:class, 'jenkins::cli::config')

      DEFAULTS.each_key do |k|
        expect(config[k]).not_to be_nil
      end
    end
  end

  before { Facter.clear }

  # we are relying on a side effect of this method being to test features /
  # load libs
  describe '#initialize' do
    it { expect(described_class.new).to be_a described_class }
  end

  describe '#[]' do
    context 'unknown config key' do
      it do
        expect { described_class.new[:foo] }.
          to raise_error(Puppet::X::Jenkins::Config::UnknownConfig)
      end
    end

    context 'no catalog' do
      let(:config) { described_class.new }

      context 'no facts' do
        include_examples 'returns default values'
      end

      context 'with facts' do
        include_examples 'returns fact values' do
          include_context 'facts'
        end
      end
    end

    context 'with catalog' do
      let(:catalog) { Puppet::Resource::Catalog.new }
      let(:config) { described_class.new(catalog) }

      context 'no jenkins::cli::config class' do
        context 'no facts' do
          include_examples 'returns default values'
        end

        context 'with facts' do
          include_examples 'returns fact values' do
            include_context 'facts'
          end
        end
      end

      context 'with jenkins::cli::config class' do
        context 'with no params' do
          before do
            jenkins = Puppet::Type.type(:component).new(
              name: 'jenkins::cli::config'
            )

            catalog.add_resource jenkins
          end

          context 'no facts' do
            include_examples 'returns default values'
          end

          context 'with facts' do
            include_examples 'returns fact values' do
              include_context 'facts'
            end
          end
        end

        context 'with all params' do
          before do
            jenkins = Puppet::Type.type(:component).new(
              name: 'jenkins::cli::config',
              cli_jar: 'cat.jar',
              url: 'http://localhost:111',
              ssh_private_key: 'cat.id_rsa',
              puppet_helper: 'cat.groovy',
              cli_tries: 222
            )

            catalog.add_resource jenkins
          end

          context 'no facts' do
            include_examples 'returns catalog values'
          end

          context 'with facts' do
            include_examples 'returns catalog values' do
              include_context 'facts'
            end
          end
        end
      end
    end
  end
end
