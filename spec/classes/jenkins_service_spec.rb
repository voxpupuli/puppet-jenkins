require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'service' do
    context 'default' do
      it do
        should contain_service('jenkins').with(
          :ensure => 'running',
          :enable => true,
        )
      end
    end

    context 'EL 7' do
      let(:facts) do
        super().merge(
          :operatingsystemrelease    => '7.1.1503',
          :operatingsystemmajrelease => '7',
          :systemd                   => true,
        )
      end

      it do
        should contain_service('jenkins').with(
          :ensure   => 'running',
          :enable   => true,
          :provider => 'systemd',
        )
      end

      let(:service_file) { '/etc/systemd/system/jenkins.service' }
      let(:startup_script) { '/usr/lib/jenkins/jenkins-run' }
      let(:sysv_file) { '/etc/init.d/jenkins' }

      it do
        should contain_file(startup_script)
          .that_notifies('Service[jenkins]')
      end
      # XXX the prior_to args check fails under puppet 3.8.7 for unknown
      # reasons...
      if Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0
        it do
          should contain_transition('stop jenkins service').with(
            :prior_to => [ "File[#{sysv_file}]" ],
          )
        end
      else
        it { should contain_transition('stop jenkins service') }
      end
      it do
        should contain_file(sysv_file)
          .with(
            :ensure => 'absent',
            :selinux_ignore_defaults => true,
          )
          .that_comes_before('Systemd::Unit_file[jenkins.service]')
      end
      it do
        should contain_systemd__unit_file('jenkins.service')
          .that_notifies('Service[jenkins]')
      end
    end

    context 'EL 6' do
      let(:facts) do
        super().merge(
          :operatingsystemrelease    => '6.6',
          :operatingsystemmajrelease => '6',
          :systemd                   => false,
        )
      end

      it do
        should contain_service('jenkins').with(
          :ensure   => 'running',
          :enable   => true,
          :provider => nil,
        )
      end
    end

    context 'managing service' do
      let(:params) {{ :service_ensure => 'stopped', :service_enable => false }}
      it do
        should contain_service('jenkins').with(
          :ensure => 'stopped',
          :enable => false,
          :provider => nil,
        )
      end
    end
  end
end
