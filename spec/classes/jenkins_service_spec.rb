require 'spec_helper'

describe 'jenkins' do
  on_supported_os(supported_os: [{ 'operatingsystem' => 'CentOS' }]).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'service' do
        context 'default' do
          it do
            is_expected.to contain_service('jenkins').with(
              ensure: 'running',
              enable: true
            )
          end
        end

        case os_facts[:os]['release']['major']
        when '7'
          context 'EL 7' do
            let(:service_file) { '/etc/systemd/system/jenkins.service' }
            let(:startup_script) { '/usr/lib/jenkins/jenkins-run' }
            let(:sysv_file) { '/etc/init.d/jenkins' }

            it { is_expected.to contain_class('jenkins').with_service_provider('systemd') }
            it { is_expected.to contain_jenkins__systemd('jenkins') }

            it do
              is_expected.to contain_service('jenkins').with(
                ensure: 'running',
                enable: true,
                provider: 'systemd'
              )
            end

            it do
              is_expected.to contain_file(startup_script).
                that_notifies('Service[jenkins]')
            end
            it do
              is_expected.to contain_transition('stop jenkins service').
                with_prior_to(["File[#{sysv_file}]"])
            end
            it do
              is_expected.to contain_file(sysv_file).
                with(
                  ensure: 'absent',
                  selinux_ignore_defaults: true
                ).
                that_comes_before('Systemd::Unit_file[jenkins.service]')
            end
            it do
              is_expected.to contain_systemd__unit_file('jenkins.service').
                that_notifies('Service[jenkins]').with_content(/^Type=simple/)
            end
          end

        when '6'
          context 'EL 6' do
            it do
              is_expected.to contain_service('jenkins').with(
                ensure: 'running',
                enable: true
              )
            end
          end

          context 'managing service' do
            let(:params) { { service_ensure: 'stopped', service_enable: false } }

            it do
              is_expected.to contain_service('jenkins').with(
                ensure: 'stopped',
                enable: false
              )
            end
          end
        end
      end
      if os_facts[:os]['release']['major'].to_i >= 7
        context 'with jenkins version 2.312' do
          let(:facts) { os_facts.merge!({ jenkins_version: '2.312' }) }

          it do
            is_expected.to contain_systemd__unit_file('jenkins.service').
              with_content(%r{^Type=forking})
          end
        end
      end

      if os_facts[:os]['release']['major'].to_i >= 7
        context 'with jenkins version 2.313' do
          let(:facts) { os_facts.merge!({ jenkins_version: '2.313' }) }

          it do
            is_expected.to contain_systemd__unit_file('jenkins.service').
              with_content(%r{^Type=simple})
          end
        end
      end
    end
  end
end
