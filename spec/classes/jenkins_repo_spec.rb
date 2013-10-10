require 'spec_helper'

describe 'jenkins::repo' do

  describe 'default' do
    let(:pre_condition) { ['class jenkins { $repo = 1 }', 'include jenkins'] }
    describe 'RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }
      it { should contain_class('jenkins::repo::el') }
    end

    describe 'Linux' do
      let(:facts) { { :osfamily => 'Linux' } }
      it { should contain_class('jenkins::repo::el') }
    end

    describe 'Debian' do
      let(:facts) { { :osfamily => 'Debian' } }
      it { should contain_class('jenkins::repo::debian') }
    end

    describe 'Unknown' do
      let(:facts) { { :osfamily => 'SomethingElse' } }
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  describe 'repo = 0' do
    let(:pre_condition) { ['class jenkins { $repo = 0 }', 'include jenkins'] }
    it { should_not contain_class('jenkins::repo::el') }
    it { should_not contain_class('jenkins::repo::debian') }
  end
end
