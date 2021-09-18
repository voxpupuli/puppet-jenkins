require 'spec_helper'

describe 'jenkins_plugins', type: :fact do
  subject { Facter.value(:jenkins_plugins) }

  let(:plugins) { {} }

  before do
    Facter.clear
    Facter.loadfacts
    allow(Puppet::Jenkins::Plugins).to receive(:available).and_return(plugins)
    Facter.fact(:kernel).stub(:value).and_return(kernel)
  end

  after { Facter.clear }

  context 'on Linux' do
    let(:kernel) { 'Linux' }

    it do
      subject
      expect(Puppet::Jenkins::Plugins).to have_received(:available)
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

  context 'on FreeBSD' do
    let(:kernel) { 'FreeBSD' }

    it { is_expected.to be_nil }
    it do
      subject
      expect(Puppet::Jenkins::Plugins).not_to have_received(:available)
    end
  end
end
