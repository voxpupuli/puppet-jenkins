require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'config' do
    context 'default' do
      it { should contain_class('jenkins::config') }
    end

    context 'create config' do
      let(:params) { { :config_hash => { 'AJP_PORT' => { 'value' => '1234' } } }}
      it { should contain_jenkins__sysconfig('AJP_PORT').with_value('1234') }
    end
  end

end
