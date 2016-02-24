require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'plugins' do
    context 'default' do
      it { should contain_class('jenkins::plugins') }
    end

    context 'install plugin' do
      let(:params) { { :plugin_hash => { 'git' => { 'version' => '1.1.1' } } } }

      it { should contain_jenkins__plugin('git').with_version('1.1.1') }
    end
  end

end
