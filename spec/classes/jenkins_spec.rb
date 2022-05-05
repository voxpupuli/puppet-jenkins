# frozen_string_literal: true

require 'spec_helper'

# Note, rspec-puppet determines the class name from the top level describe
# string.
describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default' do
        it { is_expected.to contain_class 'jenkins' }
        it { is_expected.to contain_class 'java' }
        it { is_expected.to contain_class 'jenkins::package' }
        it { is_expected.to contain_class 'jenkins::config' }
        it { is_expected.to contain_class 'jenkins::plugins' }
        it { is_expected.to contain_class 'jenkins::service' }
        it { is_expected.not_to contain_class 'jenkins::firewall' }
        it { is_expected.to contain_class 'jenkins::proxy' }
        it { is_expected.to contain_class 'jenkins::repo' }
      end

      describe 'without java' do
        let(:params) { { install_java: false } }

        it { is_expected.not_to contain_class 'java' }
      end

      describe 'without repo' do
        let(:params) { { repo: false } }

        it { is_expected.not_to contain_class 'jenkins::repo' }
      end

      describe 'with only proxy host' do
        let(:params) { { proxy_host: '1.2.3.4' } }

        it { is_expected.to contain_class('jenkins::proxy') }
      end

      describe 'with only proxy_port' do
        let(:params) { { proxy_port: 1234 } }

        it { is_expected.to contain_class('jenkins::proxy') }
      end

      describe 'with proxy_host and proxy_port' do
        let(:params) { { proxy_host: '1.2.3.4', proxy_port: 1234 } }

        it { is_expected.to contain_class 'jenkins::proxy' }
      end

      describe 'with firewall, configure_firewall => true' do
        let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
        let(:params) { { configure_firewall: true } }

        it { is_expected.to contain_class 'jenkins::firewall' }
      end

      describe 'with firewall, configure_firewall => false' do
        let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
        let(:params) { { configure_firewall: false } }

        it { is_expected.not_to contain_class 'jenkins::firewall' }
      end

      describe 'manage_datadirs =>' do
        context 'false' do
          let(:params) { { manage_datadirs: false } }

          it { is_expected.not_to contain_file('/var/lib/jenkins') }
          it { is_expected.not_to contain_file('/var/lib/jenkins/plugins') }
          it { is_expected.not_to contain_file('/var/lib/jenkins/jobs') }
        end

        context '(default)' do
          it { is_expected.to contain_file('/var/lib/jenkins') }
        end
      end

      describe 'localstatedir =>' do
        context 'undef' do
          it { is_expected.to contain_file('/var/lib/jenkins') }
        end

        context '/dne' do
          let(:params) { { localstatedir: '/dne' } }

          it { is_expected.to contain_file('/dne') }
        end
      end

      describe 'executors =>' do
        context 'undef' do
          it { is_expected.not_to contain_jenkins__cli__exec('set_num_executors') }
        end

        context '42' do
          let(:params) { { executors: 42 } }

          it do
            is_expected.to contain_jenkins__cli__exec('set_num_executors').with(
              command: ['set_num_executors', 42],
              unless: '[ $($HELPER_CMD get_num_executors) -eq 42 ]'
            )
          end

          it { is_expected.to contain_jenkins__cli__exec('set_num_executors').that_requires('Class[jenkins::cli]') }
          it { is_expected.to contain_jenkins__cli__exec('set_num_executors').that_comes_before('Class[jenkins::jobs]') }
        end
      end

      describe 'slaveagentport =>' do
        context 'undef' do
          it { is_expected.not_to contain_jenkins__cli__exec('set_slaveagent_port') }
        end

        context '7777' do
          let(:port) { 7777 }
          let(:params) { { slaveagentport: port } }

          it do
            is_expected.to contain_jenkins__cli__exec('set_slaveagent_port').with(
              command: ['set_slaveagent_port', port],
              unless: "[ $($HELPER_CMD get_slaveagent_port) -eq #{port} ]"
            )
          end

          it { is_expected.to contain_jenkins__cli__exec('set_slaveagent_port').that_requires('Class[jenkins::cli]') }
          it { is_expected.to contain_jenkins__cli__exec('set_slaveagent_port').that_comes_before('Class[jenkins::jobs]') }
        end
      end

      describe 'manage_user =>' do
        context '(default)' do
          it { is_expected.to contain_user('jenkins') }
        end

        context 'true' do
          let(:params) { { manage_user: true } }

          it { is_expected.to contain_user('jenkins') }
        end

        context 'false' do
          let(:params) { { manage_user: false } }

          it { is_expected.not_to contain_user('jenkins') }
        end
      end

      describe 'manage_service =>' do
        context '(default)' do
          it { is_expected.to contain_class 'jenkins::service' }
        end

        context 'false' do
          let(:params) do
            {
              manage_service: false
            }
          end

          it { is_expected.not_to contain_class 'jenkins::service' }
          it { is_expected.not_to contain_service 'jenkins' }
        end
      end

      describe 'user =>' do
        context '(default)' do
          it do
            is_expected.to contain_user('jenkins').with(
              ensure: 'present',
              gid: 'jenkins',
              home: '/var/lib/jenkins',
              managehome: false,
              system: true
            )
          end
        end

        context 'bob' do
          let(:params) { { user: 'bob' } }

          it do
            is_expected.to contain_user('bob').with(
              ensure: 'present',
              gid: 'jenkins',
              home: '/var/lib/jenkins',
              managehome: false,
              system: true
            )
          end
        end
      end

      describe 'manage_group =>' do
        context '(default)' do
          it { is_expected.to contain_group('jenkins') }
        end

        context 'true' do
          let(:params) { { manage_group: true } }

          it { is_expected.to contain_group('jenkins') }
        end

        context 'false' do
          let(:params) { { manage_group: false } }

          it { is_expected.not_to contain_group('jenkins') }
        end
      end

      describe 'group =>' do
        context '(default)' do
          it do
            is_expected.to contain_group('jenkins').with(
              ensure: 'present',
              system: true
            )
          end
        end

        context 'fred' do
          let(:params) { { group: 'fred' } }

          it do
            is_expected.to contain_group('fred').with(
              ensure: 'present',
              system: true
            )
          end
        end
      end

      describe 'manages state dirs' do
        [
          '/var/lib/jenkins',
          '/var/lib/jenkins/jobs',
          '/var/lib/jenkins/plugins'
        ].each do |dir|
          it do
            is_expected.to contain_file(dir).with(
              ensure: 'directory',
              owner: 'jenkins',
              group: 'jenkins',
              mode: '0755'
            )
          end
        end
      end

      describe 'with default plugins' do
        it { is_expected.to contain_jenkins__plugin 'credentials' }
      end

      describe 'with default plugins override' do
        let(:params) { { default_plugins: [] } }

        it { is_expected.not_to contain_jenkins__plugin 'credentials' }
      end

      describe 'purge_plugins =>' do
        context 'false' do
          let(:params) { { purge_plugins: false } }

          it do
            is_expected.to contain_file('/var/lib/jenkins/plugins').
              without('purge').
              without('recurse').
              without('force')
          end
        end

        context 'true' do
          let(:params) { { purge_plugins: true } }

          it do
            is_expected.to contain_file('/var/lib/jenkins/plugins').with(
              purge: true,
              recurse: true,
              force: true
            ).that_notifies('Service[jenkins]')
          end
        end

        context '(default)' do
          it do
            is_expected.to contain_file('/var/lib/jenkins/plugins').
              without('purge').
              without('recurse').
              without('force').
              without('notify')
          end
        end
      end
    end
  end
end
