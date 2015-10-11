require 'spec_helper'

describe 'jenkins::slave' do

  shared_context 'a jenkins::slave catalog' do
    it { should contain_exec('get_swarm_client') }
    it { should contain_file(slave_service_file) }
    it { should contain_service('jenkins-slave').with(:enable => true, :ensure => 'running') }
    it { should contain_user('jenkins-slave_user').with_uid(nil) }
    # Let the different platform blocks define  `slave_runtime_file` separately below
    it { should contain_file(slave_runtime_file).with_content(/^FSROOT="\/home\/jenkins-slave"$/) }
    it { should contain_file(slave_runtime_file).without_content(/ -name /) }
    it { should contain_file(slave_runtime_file).with_content(/^AUTO_DISCOVERY_ADDRESS=""$/) }

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
      it { should contain_file(slave_runtime_file).
        with_content(/--toolLocation Python-2.7=\/usr\/bin\/python2.7/).
        with_content(/--toolLocation Java-1.8=\/usr\/bin\/java/) }
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
  end

  shared_examples 'using slave_name' do
    it { should contain_file(slave_runtime_file).with_content(/^CLIENT_NAME="jenkins-slave"$/) }
  end

  describe 'RedHat' do
    let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'CentOS', :kernel => 'Linux' } }
    let(:slave_runtime_file) { '/etc/sysconfig/jenkins-slave' }
    let(:slave_service_file) { '/etc/init.d/jenkins-slave' }
    it_behaves_like 'a jenkins::slave catalog'

    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end

    it { should_not contain_package('daemon') }
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
