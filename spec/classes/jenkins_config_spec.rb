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

    context 'use config_template' do
      let(:params) { { :global_config => 'config string' } }
      it { should contain_file('/var/lib/jenkins/config.xml').with_content('config string') }

      describe 'jenkins::config::global' do
        describe 'relationships' do
          it do
            should contain_class('jenkins::config::global').
              that_requires('Class[jenkins::config]')
          end
          it do
            should contain_class('jenkins::config::global').
              that_comes_before('Class[jenkins::service]')
          end
        end
      end

    end
  end

end
