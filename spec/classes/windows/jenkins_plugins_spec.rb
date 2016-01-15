require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'Windows', :operatingsystem => 'Windows' } }

  context 'plugins' do
    context 'default' do
      it { should contain_class('jenkins::plugins') }
    end

    context 'install plugin' do
      let(:params) { { :plugin_hash => { 'git' => { 'version' => '1.1.1' } } } }

      it { should contain_jenkins__windows__plugin('git').with_version('1.1.1') }
    end
  end

end
