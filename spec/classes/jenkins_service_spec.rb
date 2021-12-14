require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}", if: os_facts[:osfamily] == 'RedHat' do
      let(:facts) { os_facts }

      context 'service' do
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
            that_notifies('Service[jenkins]')
        end
      end
    end
  end
end
