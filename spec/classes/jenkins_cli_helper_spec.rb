require 'spec_helper'

describe 'jenkins::cli_helper', :type => :class do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

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
end

