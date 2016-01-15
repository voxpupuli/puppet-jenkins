require 'spec_helper'

describe 'jenkins::security', :type => :class do
  let(:facts) {{ :osfamily => 'Windows', :operatingsystem => 'Windows' }}

  describe 'relationships' do
    it do
      should contain_class('jenkins::security').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      should contain_class('jenkins::security').
        that_comes_before('Anchor[jenkins::end]')
    end
  end
end
