require 'spec_helper'

describe 'jenkins::cli_helper', :type => :class do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  describe 'relationships' do
    it do
      should contain_class('jenkins::cli_helper').
        that_requires('Class[jenkins::cli]')
    end
    it do
      should contain_class('jenkins::cli_helper').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  it do
    should contain_file('/usr/lib/jenkins/puppet_helper.groovy').with(
      :source => 'puppet:///modules/jenkins/puppet_helper.groovy',
      :owner  => 'jenkins',
      :group  => 'jenkins',
      :mode   => '0444',
    )
  end

  context 'should accept the ssh_keyfile parameter' do
    let(:params) do
      {
        :ssh_keyfile => '/tmp/rspec'
      }
    end

    it { should contain_class 'jenkins::cli_helper' }
  end
end

