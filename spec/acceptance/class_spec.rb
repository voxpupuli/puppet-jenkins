require 'spec_helper_acceptance'

describe 'jenkins class' do
  include_context 'jenkins'

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins':
        cli => true,
      }
      EOS

      apply2(pp)
    end

    describe port(8080) do
      it {
        sleep(10) # Jenkins takes a while to start up
        should be_listening
      }
    end

    describe file("#{$libdir}/jenkins-cli.jar") do
      it { should be_file }
    end

    describe file("#{$sysconfdir}/jenkins") do
      it { should be_file }
      if fact('osfamily') == 'Debian'
        it { should contain 'AJP_PORT="-1"' }
      else
        it { should contain 'JENKINS_AJP_PORT="-1"' }
      end
    end

    describe service('jenkins') do
      it { should be_running }
      it { should be_enabled }
    end

    if fact('osfamily') == 'RedHat' and $systemd
      describe file('/etc/systemd/system/jenkins.service') do
        it { should be_file }
        it { should contain "ExecStart=#{libdir}/jenkins-run" }
      end
      describe file('/etc/init.d/jenkins') do
        it { should_not exist }
      end
      describe service('jenkins') do
        it { should be_running.under('systemd') }
      end
    else
      describe file('/etc/systemd/system/jenkins.service') do
        it { should_not exist }
      end
      describe file('/etc/init.d/jenkins') do
        it { should be_file }
      end
    end
  end # default parameters

  context 'executors' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins':
        executors => 42,
      }
      EOS

      apply2(pp)
    end

    describe port(8080) do
      # jenkins should already have been running so we shouldn't have to
      # sleep
      it { should be_listening }
    end

    describe service('jenkins') do
      it { should be_running }
      it { should be_enabled }
    end

    describe file('/var/lib/jenkins/config.xml') do
      it { should contain '  <numExecutors>42</numExecutors>' }
    end
  end # executors

  context 'slaveagentport' do
      it 'should work with no errors' do
        pp = <<-EOS
        class {'jenkins':
          slaveagentport => 7777,
        }
        EOS

        apply2(pp)
      end

      describe port(8080) do
        # jenkins should already have been running so we shouldn't have to
        # sleep
        it { should be_listening }
      end

      describe service('jenkins') do
        it { should be_running }
        it { should be_enabled }
      end

      describe file('/var/lib/jenkins/config.xml') do
        it { should contain '  <slaveAgentPort>7777</slaveAgentPort>' }
      end
    end # slaveagentport
end
