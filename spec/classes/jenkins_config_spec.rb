require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'config' do
    context 'default' do
      it { should contain_class('jenkins::config') }
    end

    context 'create config' do
      let(:params) { { :config_hash => { 'AJP_PORT' => { 'value' => '1234' } } }}
      it { should contain_jenkins__sysconfig('AJP_PORT') }
    end
  end

end
