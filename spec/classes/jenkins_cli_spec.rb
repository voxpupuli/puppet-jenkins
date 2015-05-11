require 'spec_helper'

describe 'jenkins', :type => :class do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'cli' do
    context 'default' do
      it { should_not contain_class('jenkins::cli') }
    end

    context '$cli => true' do
      let(:params) {{ :cli => true,
                      :cli_ssh_keyfile => '/path/to/key',
                      :config_hash => { 'HTTP_PORT' => { 'value' => '9000' } }
      }}
      it { should contain_class('jenkins::cli') }
      it { should contain_exec('jenkins-cli') }
      it { should contain_exec('reload-jenkins').with_command(/http:\/\/localhost:9000/) }
      it { should contain_exec('reload-jenkins').with_command(/-i\s\/path\/to\/key/) }
      it { should contain_exec('safe-restart-jenkins') }
      it { should contain_jenkins__sysconfig('HTTP_PORT').with_value('9000') }

      describe 'jenkins::cli' do
        describe 'relationships' do
          it do
            should contain_class('jenkins::cli').
              that_requires('Class[jenkins::service]')
          end
          it do
            should contain_class('jenkins::cli').
              that_comes_before('Anchor[jenkins::end]')
          end
        end
      end
    end
  end
end
