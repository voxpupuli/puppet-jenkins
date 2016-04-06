require 'spec_helper'

describe 'jenkins::slave' do

  shared_context 'a jenkins::slave catalog' do
    it do
      should contain_archive('get_swarm_client').with(
        :cleanup => false,
        :extract => false,
      )
    end
    it { should contain_file(slave_service_file) }
    it { should contain_service('jenkins-slave').with(:enable => true, :ensure => 'running') }
    # Let the different platform blocks define  `slave_runtime_file` separately below
    it { should contain_file(slave_runtime_file).with_content(/^FSROOT="\/home\/jenkins-slave"$/) }
    it { should contain_file(slave_runtime_file).without_content(/ -name /) }
    it { should contain_file(slave_runtime_file).with_content(/^AUTO_DISCOVERY_ADDRESS=""$/) }

    describe 'with manage_slave_user true and manage_client_jar enabled' do
      let(:params) { { :manage_slave_user => true, :manage_client_jar => true } }
      it { should contain_user('jenkins-slave_user').with_uid(nil).that_comes_before('Archive[get_swarm_client]') }
    end

    describe 'with manage_slave_user true and manage_client_jar false' do
      let(:params) { { :manage_slave_user => true, :manage_client_jar => false } }
      it { should contain_user('jenkins-slave_user').with_uid(nil) }
    end

    describe 'with ssl verification disabled' do
      let(:params) { { :disable_ssl_verification => true } }
      it { should contain_file(slave_runtime_file).with_content(/-disableSslVerification/) }
    end

    describe 'with auto discovery address' do
      let(:params) { { :autodiscoveryaddress => '255.255.255.0' } }
      it { should contain_file(slave_runtime_file).with_content(/^AUTO_DISCOVERY_ADDRESS="255.255.255.0"$/) }
    end

    describe 'slave_uid' do
      let(:params) { { :slave_uid => '123' } }
      it { should contain_user('jenkins-slave_user').with_uid(123) }
    end

    describe 'with a non-default $slave_home' do
      let(:home) { '/home/rspec-runner' }
      let(:params) { {:slave_home => home } }
      it { should contain_file(slave_runtime_file).with_content(/^FSROOT="#{home}"$/) }
    end

    describe 'with service disabled' do
      let(:params) { {:enable => false, :ensure => 'stopped' } }
      it { should contain_service('jenkins-slave').with(:enable => false, :ensure => 'stopped') }
    end

    describe 'with tool_locations' do
      let(:params) { { :tool_locations => 'Python-2.7:/usr/bin/python2.7 Java-1.8:/usr/bin/java' } }
      it do
        should contain_file(slave_runtime_file).
          with_content(/--toolLocation Python-2.7=\/usr\/bin\/python2.7/).
          with_content(/--toolLocation Java-1.8=\/usr\/bin\/java/)
      end
    end

    describe 'with a UI user/password' do
      let(:user) { '"frank"' }
      let(:password) { "abignale's" }
      let(:params) do
        {
          :ui_user => user,
          :ui_pass => password,
        }
      end

      it 'should escape the user' do
        should contain_file(slave_runtime_file).with_content(/^JENKINS_USERNAME='#{user}'$/)
      end

      it 'should escape the password' do
        should contain_file(slave_runtime_file).with_content(/^JENKINS_PASSWORD="#{password}"$/)
      end
    end

    describe 'with java_args' do
      let(:args) { '-Xmx2g' }
      let(:params) do
        {
          :java_args => args
        }
      end

      it 'should set java_args' do
        should contain_file(slave_runtime_file).with_content(/^JAVA_ARGS="#{args}"$/)
      end
    end
  end

  shared_examples 'using slave_name' do
    it { should contain_file(slave_runtime_file).with_content(/^CLIENT_NAME="jenkins-slave"$/) }
  end

  describe 'RedHat' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemrelease    => '6.7',
        :operatingsystemmajrelease => '6',
        :kernel                    => 'Linux',

      }
    end
    let(:slave_runtime_file) { '/etc/sysconfig/jenkins-slave' }
    let(:slave_service_file) { '/etc/init.d/jenkins-slave' }
    it_behaves_like 'a jenkins::slave catalog'

    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end

    it { should_not contain_package('daemon') }

    context '::jenkins & ::jenkins::slave should co-exist' do
      let(:pre_condition) do
        <<-'EOS'
          include ::jenkins
          include ::jenkins::slave
        EOS
      end

      it { should_not raise_error }
    end
  end

  describe 'Debian' do
    let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'debian', :lsbdistcodename => 'natty', :operatingsystem => 'Debian', :kernel => 'Linux' } }
    let(:slave_runtime_file) { '/etc/default/jenkins-slave' }
    let(:slave_service_file) { '/etc/init.d/jenkins-slave' }

    it_behaves_like 'a jenkins::slave catalog'

    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end

    it do
      should contain_package('daemon')
        .that_comes_before('Service[jenkins-slave]')
    end
  end

  describe 'Darwin' do
    let(:facts) {
      {:osfamily => 'Darwin',
       :operatingsystem => 'Darwin',
       :kernel => 'Darwin'
      }
    }
    let(:home) { '/home/jenkins-slave' }
    let(:slave_runtime_file) { "#{home}/jenkins-slave" }
    let(:slave_service_file) { '/Library/LaunchDaemons/org.jenkins-ci.slave.jnlp.plist' }

    it_behaves_like 'a jenkins::slave catalog'

    # NOTE: pending because jenkins-slave doesn't get installed on Darwin
    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end

    it { should_not contain_package('daemon') }
  end

  describe 'Unknown' do
    let(:facts) { { :ostype => 'Unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end
end
