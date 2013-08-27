require 'spec_helper'

describe 'jenkins::sysconfig' do
  let(:title) { 'JENKINS_FOO' }
  let(:params) { { :value => 'superfoo' } }

  describe 'RedHat' do
    let(:facts) { { :osfamily => 'RedHat' } }
    it { should contain_file_line('Jenkins sysconfig setting JENKINS_FOO').with_path('/etc/sysconfig/jenkins') }
  end

  describe 'Debian' do
    let(:facts) { { :osfamily => 'Debian' } }
    it { should contain_file_line('Jenkins sysconfig setting JENKINS_FOO').with_path('/etc/default/jenkins') }
  end

  describe 'Unknown' do
    let(:facts) { { :osfamily => 'Unknown' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

end
