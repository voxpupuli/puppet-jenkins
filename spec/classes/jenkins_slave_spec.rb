require 'spec_helper'

describe 'jenkins::slave' do

  shared_context 'a jenkins::slave catalog' do
    it { should contain_exec('get_swarm_client') }
    it { should contain_file('/etc/init.d/jenkins-slave') }
    it { should contain_service('jenkins-slave').with(:enable => true, :ensure => 'running') }
    it { should contain_user('jenkins-slave_user').with_uid(nil) }
    # Let the different platform blocks define  `slave_runtime_file` separately below
    it { should contain_file(slave_runtime_file).with_content(/^FSROOT="\/home\/jenkins-slave"$/) }
    it { should contain_file(slave_runtime_file).without_content(/ -name /) }

    describe 'with ssl verification disabled' do
      let(:params) { { :disable_ssl_verification => true } }
      it { should contain_file(slave_runtime_file).with_content(/-disableSslVerification/) }
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
  end

  shared_examples 'using slave_name' do
    it { should contain_file(slave_runtime_file).with_content(/^CLIENT_NAME="jenkins-slave"$/) }
  end

  describe 'RedHat' do
    let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'CentOS' } }
    let(:slave_runtime_file) { '/etc/sysconfig/jenkins-slave' }

    it_behaves_like 'a jenkins::slave catalog'

    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end
  end

  describe 'Debian' do
    let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'debian', :lsbdistcodename => 'natty', :operatingsystem => 'Debian' } }
    let(:slave_runtime_file) { '/etc/default/jenkins-slave' }

    it_behaves_like 'a jenkins::slave catalog'

    describe 'with slave_name' do
      let(:params) { { :slave_name => 'jenkins-slave' } }
      it_behaves_like 'using slave_name'
    end
  end

  describe 'Unknown' do
    let(:facts) { { :ostype => 'Unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end
end
