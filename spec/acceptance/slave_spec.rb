# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'jenkins::slave class' do
  context 'default parameters' do
    sysconfdirs = {
      'RedHat' => '/etc/sysconfig',
      'Debian' => '/etc/default',
      'Archlinux' => '/etc/conf.d',
    }

    include_examples 'an idempotent resource' do
      let(:manifest) { 'include jenkins::slave' }
    end

    describe file('/etc/systemd/system/jenkins-slave.service') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'ExecStart=/home/jenkins-slave/jenkins-slave-run' }
    end

    describe file("#{sysconfdirs[fact('os.family')]}/jenkins-slave") do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end

    describe file('/home/jenkins-slave/swarm-client-2.2-jar-with-dependencies.jar') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
    end

    describe service('jenkins-slave') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end

  context 'parameters' do
    before(:all) do
      pp = <<-EOS
        # attempt to make the swarm client the only running 'java' process
        service { jenkins: ensure => 'stopped' }
      EOS

      apply_manifest(pp)
    end

    context 'ui_user/ui_pass' do
      include_examples 'an idempotent resource' do
        let(:manifest) do
          <<~PUPPET
            class { 'jenkins::slave':
              ui_user => 'imauser',
              ui_pass => 'imapass',
            }
          PUPPET
        end
      end

      describe process('java') do
        its(:user) { is_expected.to eq 'jenkins-slave' }
        its(:args) { is_expected.to match %r{-username imauser} }
        its(:args) { is_expected.to match %r{-passwordEnvVariable JENKINS_PASSWORD} }
        its(:args) { is_expected.not_to match %r{imapass} }
      end
    end

    context 'disable_clients_unique_id' do
      context 'true' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                disable_clients_unique_id => true,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-disableClientsUniqueId} }
        end
      end

      context 'false' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                disable_clients_unique_id => false,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-disableClientsUniqueId} }
        end
      end
    end

    context 'disable_ssl_verification' do
      context 'true' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                disable_ssl_verification => true,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-disableSslVerification} }
        end
      end

      context 'false' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                disable_ssl_verification => false,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-disableSslVerification} }
        end
      end
    end

    context 'delete_existing_clients' do
      context 'true' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                delete_existing_clients => true,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-deleteExistingClients} }
        end
      end

      context 'false' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                delete_existing_clients => false,
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-deleteExistingClients} }
        end
      end
    end

    context 'labels' do
      context 'multiple labels in array' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                labels => ['foo', 'bar', 'baz'],
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-labels foo bar baz} }
        end
      end
    end

    context 'tool_locations' do
      tool_locations = 'Python-2.7:/usr/bin/python2.7 Java-1.8:/usr/bin/java'

      context tool_locations do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                tool_locations => '#{tool_locations}',
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{--toolLocation Python-2\.7=/usr/bin/python2\.7} }
          its(:args) { is_expected.to match %r{--toolLocation Java-1\.8=/usr/bin/java} }
        end
      end
    end

    context 'tunnel' do
      tunnel = 'localhost:9000'

      context tunnel do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class { 'jenkins::slave':
                tunnel => '#{tunnel}',
              }
            PUPPET
          end
        end

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-tunnel localhost:9000} }
        end
      end
    end
  end
end
