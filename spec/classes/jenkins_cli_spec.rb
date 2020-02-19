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
              libdir: '/path/to/libdir',
              config_hash: { 'HTTP_PORT' => { 'value' => '9000' } } }
          end

          it { is_expected.to contain_class('jenkins::cli') }
          it { is_expected.to contain_exec('jenkins-cli') }
          it { is_expected.to contain_exec('reload-jenkins').with_command(%r{http://localhost:9000}) }
          it { is_expected.to contain_exec('reload-jenkins').with_command(%r{-i\s'/path/to/key'}) }
          it { is_expected.to contain_exec('reload-jenkins').that_requires('File[/path/to/libdir/jenkins-cli.jar]') }
          it { is_expected.to contain_exec('safe-restart-jenkins').with('environment' => nil) }
          it { is_expected.to contain_jenkins__sysconfig('HTTP_PORT').with_value('9000') }

<<<<<<< HEAD
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
=======
    context '$cli => true' do
      let(:params) {{ :cli => true,
                      :cli_ssh_keyfile => '/path/to/key',
                      :config_hash => { 'HTTP_PORT' => { 'value' => '9000' } }}
      }
      it { should contain_class('jenkins::cli') }
      it { should contain_exec('jenkins-cli') }
      it { should contain_exec('reload-jenkins').with_command(/http:\/\/localhost:9000/) }
      it { should contain_exec('reload-jenkins').with_command(/-i\s'\/path\/to\/key'/) }
      it { should contain_exec('safe-restart-jenkins') }
      it { should contain_exec('safe-restart-jenkins').with('environment' => nil) }
      it { should contain_jenkins__sysconfig('HTTP_PORT').with_value('9000') }

      describe 'jenkins::cli' do
        describe 'relationships' do
          it do
            should contain_class('jenkins::cli').
              that_requires('Class[jenkins::service]')
>>>>>>> 14d095a... CIP-389 Resolve credential leak via ps with cli
          end

          context '$cli_password is defined' do
            let(:params) do
              {
                version: '2.54',
                libdir: '/path/to/libdir',
                cli: true,
                cli_remoting_free: true,
                cli_username: 'user01',
                cli_password: 'password01'
              }
            end

            it do
              is_expected.to contain_exec('safe-restart-jenkins').with(
                'environment' => [
                  'JENKINS_USER_ID=user01',
                  'JENKINS_API_TOKEN=password01'
                ]
              )
            end
          end

          context '$cli_password is defined' do
            let(:params) do
              {
                version: '2.54',
                libdir: '/path/to/libdir',
                cli: true,
                cli_remoting_free: true,
                cli_username: 'user01',
                cli_password: 'password01'
              }
            end

            it do
              is_expected.to contain_exec('safe-restart-jenkins').with(
                'environment' => [
                  'JENKINS_USER_ID=user01',
                  'JENKINS_API_TOKEN=password01'
                ]
              )
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
