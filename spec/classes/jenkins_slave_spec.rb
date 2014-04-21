require 'spec_helper'

describe 'jenkins::slave' do

  describe 'RedHat' do
    let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'CentOS' } }

    describe 'default' do
      it { should contain_exec('get_swarm_client') }
      it { should contain_file('/etc/init.d/jenkins-slave') }
      it { should contain_service('jenkins-slave') }
      it { should contain_user('jenkins-slave_user').with_uid(nil) }
      it { should contain_file('/etc/init.d/jenkins-slave').with_content(/-fsroot \/home\/jenkins-slave/) }
    end

    describe 'with ssl verification disabled' do
      let(:params) { { :disable_ssl_verification => true } }
      it { should contain_file('/etc/init.d/jenkins-slave').with_content(/-disableSslVerification/) }
    end

    describe 'slave_uid' do
      let(:params) { { :slave_uid => '123' } }
      it { should contain_user('jenkins-slave_user').with_uid(123) }
    end
  end

  describe 'Debian' do
    let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'debian', :lsbdistcodename => 'natty', :operatingsystem => 'Debian' } }
    describe 'default' do
      it { should contain_exec('get_swarm_client') }
      it { should contain_file('/etc/init.d/jenkins-slave') }
      it { should contain_service('jenkins-slave') }
      it { should contain_user('jenkins-slave_user').with_uid(nil) }
      it { should contain_file('/etc/default/jenkins-slave').with_content(/-fsroot \/home\/jenkins-slave/) }
    end
    describe 'with ssl verification disabled' do
      let(:params) { { :disable_ssl_verification => true } }
      it { should contain_file('/etc/default/jenkins-slave').with_content(/-disableSslVerification/) }
    end
  end

  describe 'Unknown' do
    let(:facts) { { :ostype => 'Unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

end
