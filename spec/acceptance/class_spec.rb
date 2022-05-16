# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'jenkins class' do
  context 'default parameters' do
    include_examples 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          class {'jenkins':
            cli => true,
          }
        PUPPET
      end
    end

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

    describe process('java') do
      it { is_expected.to be_running }
      its(:args) { is_expected.to match(%r{-Djenkins\.install\.runSetupWizard=false}) }
    end
  end

  context 'executors' do
    include_examples 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          class {'jenkins':
            executors => 42,
          }
        PUPPET
      end
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
  end

  context 'slaveagentport' do
    include_examples 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          class {'jenkins':
            slaveagentport => 7777,
          }
        PUPPET
      end
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
  end
end
