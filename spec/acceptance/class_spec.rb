require 'spec_helper_acceptance'

describe 'jenkins class' do
  context 'default parameters' do
    pp = <<-EOS
    class {'jenkins':
      cli => true,
    }
    EOS

    apply2(pp)

    describe port(8080) do
      it {
        sleep(10) # Jenkins takes a while to start up
        is_expected.to be_listening
      }
    end

    describe file('/usr/share/java/jenkins-cli.jar') do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_writable.by('owner') }
      it { is_expected.to be_readable.by('group') }
      it { is_expected.to be_readable.by('others') }
    end

    describe file('/etc/systemd/system/jenkins.service.d/puppet-overrides.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Environment=' }
    end

    describe service('jenkins') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end # default parameters

  context 'executors' do
    pp = <<-EOS
    class {'jenkins':
      executors => 42,
    }
    EOS

    apply2(pp)

    describe port(8080) do
      # jenkins should already have been running so we shouldn't have to
      # sleep
      it { is_expected.to be_listening }
    end

    describe service('jenkins') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe file('/var/lib/jenkins/config.xml') do
      it { is_expected.to contain '  <numExecutors>42</numExecutors>' }
    end
  end # executors

  context 'slaveagentport' do
    pp = <<-EOS
      class {'jenkins':
        slaveagentport => 7777,
      }
      EOS

    apply2(pp)

    describe port(8080) do
      # jenkins should already have been running so we shouldn't have to
      # sleep
      it { is_expected.to be_listening }
    end

    describe service('jenkins') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe file('/var/lib/jenkins/config.xml') do
      it { is_expected.to contain '  <slaveAgentPort>7777</slaveAgentPort>' }
    end
  end # slaveagentport
end
