require 'spec_helper'
require 'lib/facter/jenkins'

describe Puppet::Jenkins::Facts do
  describe '.plugins_str' do
    subject(:plugins_str) { described_class.plugins_str }
    let(:plugins) { {} }

    before :each do
      Puppet::Jenkins::Plugins.should_receive(:available).and_return(plugins)
    end

    context 'with no plugins' do
      it { should be_instance_of String }
      it { should be_empty }
    end

    context 'with one plugin' do
      let(:plugins) do
        {
          'greenballs' => {:plugin_version => '1.1', :description => 'rspec'}
        }
      end

      it { should be_instance_of String }
      it { should eql 'greenballs 1.1' }
    end

    context 'with multiple plugins' do
      let(:plugins) do
        {
          'greenballs' => {:plugin_version => '1.1', :description => 'rspec'},
          'git' => {:plugin_version => '1.7', :description => 'rspec'}
        }
      end

      it { should be_instance_of String }
      it { should eql 'git 1.7, greenballs 1.1' }
    end
  end

  describe 'jenkins_plugins fact', :type => :fact do
    let(:fact) { Facter.fact(:jenkins_plugins) }
    subject(:plugins) { fact.value }

    before :each do
      Facter.fact(:kernel).stubs(:value).returns(kernel)
      Puppet::Jenkins::Facts.install
    end

    context 'on Linux' do
      let(:kernel) { 'Linux' }

      context 'with no plugins' do
        it { should be_nil }
      end

      context 'with plugins' do
        let(:plugins_str) { 'ant 1.2, git 2.0.1' }
        before :each do
          Jenkins::Facts::Plugins.should_receive(:plugins).and_return(plugins_str)
        end

        it { should eql(plugins_str) }
      end
    end

    context 'on FreeBSD' do
      let(:kernel) { 'FreeBSD' }

      it { should be_nil }
    end
  end
end
