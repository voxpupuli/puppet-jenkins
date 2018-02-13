require 'spec_helper'
require 'lib/facter/jenkins'

describe Puppet::Jenkins::Facts do
  describe '.plugins_str' do
    subject(:plugins_str) { described_class.plugins_str }

    let(:plugins) { {} }

    before do
      Puppet::Jenkins::Plugins.should_receive(:available).and_return(plugins)
    end

    context 'with no plugins' do
      it { is_expected.to be_instance_of String }
      it { is_expected.to be_empty }
    end

    context 'with one plugin' do
      let(:plugins) do
        {
          'greenballs' => { plugin_version: '1.1', description: 'rspec' }
        }
      end

      it { is_expected.to be_instance_of String }
      it { is_expected.to eql 'greenballs 1.1' }
    end

    context 'with multiple plugins' do
      let(:plugins) do
        {
          'greenballs' => { plugin_version: '1.1', description: 'rspec' },
          'git' => { plugin_version: '1.7', description: 'rspec' }
        }
      end

      it { is_expected.to be_instance_of String }
      it { is_expected.to eql 'git 1.7, greenballs 1.1' }
    end
  end

  describe 'jenkins_plugins fact', type: :fact do
    subject(:plugins) { fact.value }

    let(:fact) { Facter.fact(:jenkins_plugins) }

    before do
      Facter.fact(:kernel).stubs(:value).returns(kernel)
      described_class.install
    end

    context 'on Linux' do
      let(:kernel) { 'Linux' }

      context 'with no plugins' do
        it { is_expected.to be_nil }
      end

      context 'with plugins' do
        let(:plugins_str) { 'ant 1.2, git 2.0.1' }

        before do
          Jenkins::Facts::Plugins.should_receive(:plugins).and_return(plugins_str)
        end

        it { is_expected.to eql(plugins_str) }
      end
    end

    context 'on FreeBSD' do
      let(:kernel) { 'FreeBSD' }

      it { is_expected.to be_nil }
    end
  end
end
