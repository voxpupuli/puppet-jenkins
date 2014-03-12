require 'spec_helper'
require 'lib/facter/jenkins'

describe 'jenkins_plugins fact', :type => :fact do
  let(:fact) { Facter.fact(:jenkins_plugins) }
  subject(:plugins) { fact.value }

  before :each do
    Facter.fact(:kernel).stubs(:value).returns(kernel)
    Jenkins::Facts.add_facts
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

