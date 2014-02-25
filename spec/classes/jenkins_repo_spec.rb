require 'spec_helper'

describe 'jenkins::repo' do

  describe 'default' do
    let(:pre_condition) { ['class jenkins { $repo = true }', 'include jenkins'] }
    describe 'RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }
      it { should contain_class('jenkins::repo::el') }
    end

    describe 'Linux' do
      let(:facts) { { :osfamily => 'Linux' } }
      it { should contain_class('jenkins::repo::el') }
    end

    describe 'Suse' do
      let(:facts) { { :osfamily => 'Suse' } }
      it { should contain_class('jenkins::repo::suse') }
    end

    describe 'Debian' do
      let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'debian' } }
      it { should contain_class('jenkins::repo::debian') }
    end

    describe 'Unknown' do
      let(:facts) { { :osfamily => 'SomethingElse' } }
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  describe 'repo = 0' do
    let(:pre_condition) { ['class jenkins { $repo = false }', 'include jenkins'] }
    it { should_not contain_class('jenkins::repo::el') }
    it { should_not contain_class('jenkins::repo::suse') }
    it { should_not contain_class('jenkins::repo::debian') }
  end
end
