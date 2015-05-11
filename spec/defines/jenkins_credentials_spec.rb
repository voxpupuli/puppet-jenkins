require 'spec_helper'

describe 'jenkins::credentials', :type => :define do
  let(:title) { 'foo' }
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'RedHat' }}

  describe 'relationships' do
    let(:params) {{ :password => 'foo' }}
    it do
      should contain_jenkins__credentials('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      should contain_jenkins__credentials('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end
end
