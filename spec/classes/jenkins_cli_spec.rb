# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'cli' do
        context 'default' do
          it { is_expected.to contain_class('jenkins').with(cli: true) }
          it { is_expected.to contain_class('jenkins::cli') }
          it { is_expected.to contain_class('jenkins::cli_helper') }
        end

        context '$cli => true' do
          let(:params) do
            { cli: true,
              cli_ssh_keyfile: '/path/to/key',
              cli_username: 'myuser',
              libdir: '/path/to/libdir',
              config_hash: { 'JENKINS_PORT' => { 'value' => '9000' } } }
          end

          it { is_expected.to contain_class('jenkins::cli') }
          it { is_expected.to contain_exec('jenkins-cli') }
          it { is_expected.to contain_exec('reload-jenkins').with_command(%r{http://localhost:9000}) }
          it { is_expected.to contain_exec('reload-jenkins').with_command(%r{-i\s'/path/to/key'}) }
          it { is_expected.to contain_exec('reload-jenkins').that_requires('File[/path/to/libdir/jenkins-cli.jar]') }
          it { is_expected.to contain_exec('safe-restart-jenkins') }

          describe 'jenkins::cli' do
            describe 'relationships' do
              it do
                is_expected.to contain_class('jenkins::cli').
                  that_requires('Class[jenkins::service]')
              end

              it do
                is_expected.to contain_class('jenkins::cli').
                  that_comes_before('Anchor[jenkins::end]')
              end
            end
          end
        end

        context '$cli => false' do
          let(:params) { { cli: false } }

          it { is_expected.not_to contain_class('jenkins::cli') }
          it { is_expected.not_to contain_class('jenkins::cli_helper') }
        end
      end
    end
  end
end
