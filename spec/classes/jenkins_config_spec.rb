require 'spec_helper'

describe 'jenkins', :type => :module do
  context 'on RedHat' do
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
        it { should contain_jenkins__plugin('credentials') }
        it do
          should contain_jenkins__sysconfig('JENKINS_JAVA_OPTIONS')
            .with_value('-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false')
        end
        it do
          should contain_jenkins__sysconfig('JENKINS_AJP_PORT').with_value('-1')
        end
      end
    end
  end

  context 'on OpenBSD' do
    let(:facts) { { :osfamily => 'OpenBSD', :operatingsystem => 'OpenBSD' } }
    context 'config' do
      context 'default' do
        it { should contain_class('jenkins::config') }
      end
    end
  end
end
