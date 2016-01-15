require 'spec_helper'

describe 'jenkins::cli_helper', :type => :class do
  let(:facts) { { :osfamily => 'Windows', :operatingsystem => 'Windows' } }

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
    should contain_file('C:/Program Files (x86)/Jenkins/puppet_helper.groovy').with(
      :source => 'puppet:///modules/jenkins/puppet_helper.groovy',
    )
  end
end