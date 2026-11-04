# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'casc' do
        context 'default' do
          it { is_expected.to contain_class('jenkins::casc') }
          it { is_expected.not_to contain_file('/var/lib/jenkins/jenkins.yaml') }
        end

        context 'with casc_config' do
          let(:params) do
            {
              casc_config: {
                'jenkins' => {
                  'securityRealm' => {
                    'ldap' => {
                      'configurations' => [
                        {
                          'server' => 'ldaps://dc1.example.com:636',
                          'rootDN' => 'DC=example,DC=com',
                          'userSearch' => 'sAMAccountName={0}',
                        },
                      ],
                    },
                  },
                },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it do
            is_expected.to contain_file('/var/lib/jenkins/jenkins.yaml').with(
              ensure: 'file',
              owner: 'jenkins',
              group: 'jenkins',
              mode: '0600'
            ).that_requires('Package[jenkins]').that_notifies('Class[jenkins::service]')
          end

          it do
            is_expected.to contain_file('/var/lib/jenkins/jenkins.yaml').
              with_content(sensitive(%r{server: ldaps://dc1\.example\.com:636}))
          end
        end

        context 'with casc_config and custom localstatedir' do
          let(:params) { { casc_config: { 'jenkins' => { 'systemMessage' => 'hi' } }, localstatedir: '/srv/jenkins' } }

          it { is_expected.to contain_file('/srv/jenkins/jenkins.yaml').with_content(sensitive(%r{systemMessage: hi})) }
        end

        context 'with casc_config and manage_service false' do
          let(:params) { { casc_config: { 'jenkins' => { 'systemMessage' => 'hi' } }, manage_service: false } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/var/lib/jenkins/jenkins.yaml') }
        end
      end
    end
  end
end
