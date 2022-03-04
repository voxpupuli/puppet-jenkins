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

          expected = case os_facts[:os]['family']
                     when 'Debian'
                       {
                         'JAVA_ARGS' => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false',
                         'AJP_PORT' => '-1'
                       }
                     when 'RedHat', 'Suse'
                       {
                         'JENKINS_JAVA_OPTIONS' => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false',
                         'JENKINS_AJP_PORT' => '-1'
                       }
                     else
                       {}
                     end

          it { is_expected.to have_jenkins__sysconfig_resource_count(expected.length) }

          expected.each do |var, value|
            it { is_expected.to contain_jenkins__sysconfig(var).with_value(value) }
          end
        end

        context 'create config' do
          let(:params) { { config_hash: { 'AJP_PORT' => { 'value' => '1234' } } } }

          it { is_expected.to contain_jenkins__sysconfig('AJP_PORT').with_value('1234') }
        end
      end
    end
  end
end
