require 'spec_helper'

describe 'jenkins::cli_helper', type: :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  describe 'relationships' do
    it do
      is_expected.to contain_class('jenkins::cli_helper').
        that_requires('Class[jenkins::cli]')
    end
    it do
      is_expected.to contain_class('jenkins::cli_helper').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  it do
    is_expected.to contain_file('/usr/lib/jenkins/puppet_helper.groovy').with(
      source: 'puppet:///modules/jenkins/puppet_helper.groovy',
      owner: 'jenkins',
      group: 'jenkins',
      mode: '0444'
    )
  end
end
