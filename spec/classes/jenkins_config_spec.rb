require 'spec_helper'

describe 'jenkins', type: :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  context 'config' do
    context 'default' do
      it { is_expected.to contain_class('jenkins::config') }
      it { is_expected.to contain_jenkins__plugin('credentials') }
      it do
        is_expected.to contain_jenkins__sysconfig('JENKINS_JAVA_OPTIONS').
          with_value('-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false')
      end
      it do
        is_expected.to contain_jenkins__sysconfig('JENKINS_AJP_PORT').with_value('-1')
      end
    end

    context 'create config' do
      let(:params) { { config_hash: { 'AJP_PORT' => { 'value' => '1234' } } } }

      it { is_expected.to contain_jenkins__sysconfig('AJP_PORT').with_value('1234') }
    end
  end
end
