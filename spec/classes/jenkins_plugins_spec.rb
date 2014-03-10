require 'spec_helper'

describe 'jenkins' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { [] }

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
