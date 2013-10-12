require 'spec_helper'

describe 'jenkins::slave' do

  describe 'RedHat' do
    let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'CentOS' } }

    describe 'default' do
      it { should contain_exec('get_swarm_client') }
      it { should contain_file('/etc/init.d/jenkins-slave') }
      it { should contain_service('jenkins-slave') }
      it { should contain_user('jenkins-slave_user').with_uid(nil) }
    end

    describe 'slave_uid' do
      let(:params) { { :slave_uid => '123' } }
      it { should contain_user('jenkins-slave_user').with_uid(123) }
    end
  end

  describe 'Debian' do
    let(:facts) { { :ostype => 'Debian' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  describe 'Unknown' do
    let(:facts) { { :ostype => 'Unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

end
