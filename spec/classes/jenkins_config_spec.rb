# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'config' do
        context 'default' do
          it { is_expected.to contain_class('jenkins::config') }
          it { is_expected.to contain_jenkins__plugin('credentials') }

          it do
            is_expected.to contain_file('/etc/systemd/system/jenkins.service.d/puppet-overrides.conf').
              with_content <<~CONFIG
                [Service]
                Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"
              CONFIG
          end
        end

        context 'create config' do
          let(:params) { { config_hash: { 'AJP_PORT' => { 'value' => '1234' } }, service_override: { 'WorkingDirectory' => '/example/path' } } }

          it do
            is_expected.to contain_file('/etc/systemd/system/jenkins.service.d/puppet-overrides.conf').
              with_content <<~CONFIG
                [Service]
                Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"
                Environment="AJP_PORT=1234"
                WorkingDirectory=/example/path
              CONFIG
          end
        end
      end
    end
  end
end
