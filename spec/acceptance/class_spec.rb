require 'spec_helper_acceptance'

describe 'jenkins class' do
  include_context 'jenkins'

  context 'default parameters' do
    it 'works with no errors' do
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
        cli               => true,
      }
      EOS

      apply2(pp)
    end

    describe port(8080) do
      it {
        sleep(10) # Jenkins takes a while to start up
        is_expected.to be_listening
      }
    end

    describe file("#{$libdir}/jenkins-cli.jar") do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_writable.by('owner') }
      it { is_expected.to be_readable.by('group') }
      it { is_expected.to be_readable.by('others') }
    end

    describe file("#{$sysconfdir}/jenkins") do
      it { is_expected.to be_file }
      if fact('osfamily') == 'Debian'
        it { is_expected.to contain 'AJP_PORT="-1"' }
      else
        it { is_expected.to contain 'JENKINS_AJP_PORT="-1"' }
      end
    end

    describe service('jenkins') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    if fact('osfamily') == 'RedHat' && $systemd
      describe file('/etc/systemd/system/jenkins.service') do
        it { is_expected.to be_file }
        it { is_expected.to contain "ExecStart=#{libdir}/jenkins-run" }
      end
      describe file('/etc/init.d/jenkins') do
        it { is_expected.not_to exist }
      end
      describe service('jenkins') do
        it { is_expected.to be_running.under('systemd') }
      end
    else
      describe file('/etc/systemd/system/jenkins.service') do
        it { is_expected.not_to exist }
      end
      describe file('/etc/init.d/jenkins') do
        it { is_expected.to be_file }
      end
    end
  end # default parameters

  context 'executors' do
    it 'works with no errors' do
      pp = <<-EOS
      class {'jenkins':
        executors         => 42,
        cli_remoting_free => true,
      }
      EOS

      apply2(pp)
    end

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
    it 'works with no errors' do
      pp = <<-EOS
        class {'jenkins':
          slaveagentport    => 7777,
          cli_remoting_free => true,
        }
        EOS

      apply2(pp)
    end

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
