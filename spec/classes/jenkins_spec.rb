require 'spec_helper'

# Note, rspec-puppet determines the class name from the top level describe
# string.
describe 'jenkins', :type => :module do
  describe 'on RedHat' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemrelease    => '6.7',
        :operatingsystemmajrelease => '6',
      }
    end

    describe 'default' do
      it { should contain_class 'jenkins' }
      it { should contain_class 'java' }
      it { should contain_class 'jenkins::package' }
      it { should contain_class 'jenkins::config' }
      it { should contain_class 'jenkins::plugins' }
      it { should contain_class 'jenkins::service' }
      it { should_not contain_class 'jenkins::firewall' }
      it { should_not contain_class 'jenkins::proxy' }
      it { should contain_class 'jenkins::repo' }
      it { should contain_class 'jenkins::repo::el' }
      it { should_not contain_class 'jenkins::repo::debian' }
      it { should_not contain_class 'jenkins::repo::suse' }
    end

    describe 'without java' do
      let(:params) { { :install_java => false } }
      it { should_not contain_class 'java' }
    end

    describe 'without repo' do
      let(:params) { { :repo => false } }
      it { should_not contain_class 'jenkins::repo' }
    end

    describe 'with only proxy host' do
      let(:params) { { :proxy_host => '1.2.3.4' } }
      it { should_not contain_class('jenkins::proxy') }
    end

    describe 'with only proxy_port' do
      let(:params) { { :proxy_port => 1234 } }
      it { should_not contain_class('jenkins::proxy') }
    end

    describe 'with proxy_host and proxy_port' do
      let(:params) { { :proxy_host => '1.2.3.4', :proxy_port => 1234 } }
      it { should contain_class 'jenkins::proxy'}
    end

    describe 'with firewall, configure_firewall => true' do
      let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
      let(:params) { { :configure_firewall => true } }
      it { should contain_class 'jenkins::firewall' }
    end

    describe 'with firewall, configure_firewall => false' do
      let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
      let(:params) { { :configure_firewall => false } }
      it { should_not contain_class 'jenkins::firewall' }
    end

    describe 'with firewall, configure_firewall unset' do
      let(:pre_condition) { 'define firewall ($action, $state, $dport, $proto) {}' }
      it { expect { should raise_error(Puppet::Error) } }
    end

    describe 'manage_datadirs =>' do
      context 'false' do
        let(:params) {{ :manage_datadirs => false }}
        it { should_not contain_file('/var/lib/jenkins') }
        it { should_not contain_file('/var/lib/jenkins/plugins') }
        it { should_not contain_file('/var/lib/jenkins/jobs') }
      end

      context '"false"' do
        let(:params) {{ :manage_datadirs => 'false' }}
        it { should raise_error(Puppet::Error, /is not a boolean/) }
      end

      context '(default)' do
        it { should contain_file('/var/lib/jenkins') }
      end
    end

    describe 'localstatedir =>' do
      context 'undef' do
        it { should contain_file('/var/lib/jenkins') }
      end

      context '/dne' do
        let(:params) {{ :localstatedir => '/dne' }}
        it { should contain_file('/dne') }
      end

      context './tmp' do
        let(:params) {{ :localstatedir => './tmp' }}
        it { should raise_error(Puppet::Error, /is not an absolute path/) }
      end
    end

    describe 'executors =>' do
      context 'undef' do
        it { should_not contain_jenkins__cli__exec('set_num_executors') }
      end

      context '42' do
        let(:params) {{ :executors => 42 }}

        it do
          should contain_jenkins__cli__exec('set_num_executors').with(
            :command => ['set_num_executors', 42],
            :unless  => '[ $($HELPER_CMD get_num_executors) -eq 42 ]',
          )
        end
        it { should contain_jenkins__cli__exec('set_num_executors').that_requires('Class[jenkins::cli]') }
        it { should contain_jenkins__cli__exec('set_num_executors').that_comes_before('Class[jenkins::jobs]') }
      end

      context '{}' do
        let(:params) {{ :executors => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /to be an Integer/)
        end
      end
    end # executors =>

    describe 'slaveagentport =>' do
      context 'undef' do
        it { should_not contain_jenkins__cli__exec('set_slaveagent_port') }
      end

      context '7777' do
        let(:port) { 7777 }
        let(:params) {{ :slaveagentport => port }}

        it do
          should contain_jenkins__cli__exec('set_slaveagent_port').with(
            :command => ['set_slaveagent_port', port],
            :unless  => "[ $($HELPER_CMD get_slaveagent_port) -eq #{port} ]",
          )
        end
        it { should contain_jenkins__cli__exec('set_slaveagent_port').that_requires('Class[jenkins::cli]') }
        it { should contain_jenkins__cli__exec('set_slaveagent_port').that_comes_before('Class[jenkins::jobs]') }
      end

      context '{}' do
        let(:params) {{ :slaveagentport => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /to be an Integer/)
        end
      end
    end # slaveagentport =>

    describe 'manage_user =>' do
      context '(default)' do
        it { should contain_user('jenkins') }
      end

      context 'true' do
        let(:params) {{ :manage_user => true }}
        it { should contain_user('jenkins') }
      end

      context 'false' do
        let(:params) {{ :manage_user => false }}
        it { should_not contain_user('jenkins') }
      end

      context '{}' do
        let(:params) {{ :manage_user => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean./)
        end
      end
    end # manage_user =>

    describe 'user =>' do
      context '(default)' do
        it do
          should contain_user('jenkins').with(
            :ensure     => 'present',
            :gid        => 'jenkins',
            :home       => '/var/lib/jenkins',
            :managehome => false,
            :system     => true,
          )
        end
      end

      context 'bob' do
        let(:params) {{ :user => 'bob' }}

        it do
          should contain_user('bob').with(
            :ensure     => 'present',
            :gid        => 'jenkins',
            :home       => '/var/lib/jenkins',
            :managehome => false,
            :system     => true,
          )
        end
      end

      context '{}' do
        let(:params) {{ :user => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a string./)
        end
      end
    end # user =>

    describe 'manage_group =>' do
      context '(default)' do
        it { should contain_group('jenkins') }
      end

      context 'true' do
        let(:params) {{ :manage_group => true }}
        it { should contain_group('jenkins') }
      end

      context 'false' do
        let(:params) {{ :manage_group => false }}
        it { should_not contain_group('jenkins') }
      end

      context '{}' do
        let(:params) {{ :manage_group => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a boolean./)
        end
      end
    end # manage_group =>

    describe 'group =>' do
      context '(default)' do
        it do
          should contain_group('jenkins').with(
            :ensure => 'present',
            :system => true,
          )
        end
      end

      context 'fred' do
        let(:params) {{ :group => 'fred' }}

        it do
          should contain_group('fred').with(
            :ensure => 'present',
            :system => true,
          )
        end
      end

      context '{}' do
        let(:params) {{ :group => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a string./)
        end
      end
    end # group =>

    describe 'manages state dirs' do
      [
        '/var/lib/jenkins',
        '/var/lib/jenkins/jobs',
        '/var/lib/jenkins/plugins',
      ].each do |dir|
        it do
          should contain_file(dir).with(
            :ensure => 'directory',
            :owner  => 'jenkins',
            :group  => 'jenkins',
            :mode   => '0755',
          )
        end
      end
    end # manages state dirs
  end
end
