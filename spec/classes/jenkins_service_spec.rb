require 'spec_helper'

describe 'jenkins', type: :class do
  on_supported_os.each do |os, facts|

    next unless facts[:os]['family'] == 'RedHat'

    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end
      context 'service' do
        context 'default' do
          it do
            is_expected.to contain_service('jenkins').with(
              ensure: 'running',
              enable: true
            )
          end
        end

        case facts[:os]['release']['major']
        when '7'
          context 'EL 7' do
            let(:service_file) { '/etc/systemd/system/jenkins.service' }
            let(:startup_script) { '/usr/lib/jenkins/jenkins-run' }
            let(:sysv_file) { '/etc/init.d/jenkins' }

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
            # XXX the prior_to args check fails under puppet 3.8.7 for unknown
            # reasons...
            if Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
              it do
                is_expected.to contain_transition('stop jenkins service').with(
                  prior_to: ["File[#{sysv_file}]"]
                )
              end
            else
              it { is_expected.to contain_transition('stop jenkins service') }
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
                that_notifies('Service[jenkins]')
            end
          end
        when '6'
          context 'EL 6' do
            it do
              is_expected.to contain_service('jenkins').with(
                ensure: 'running',
                enable: true,
              )
            end
          end

          context 'managing service' do
            let(:params) { { service_ensure: 'stopped', service_enable: false } }

            it do
              is_expected.to contain_service('jenkins').with(
                ensure: 'stopped',
                enable: false,
              )
            end
          end
        end
      end
    end
  end
end
