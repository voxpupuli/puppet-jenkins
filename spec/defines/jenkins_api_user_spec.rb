require 'spec_helper'

describe 'jenkins::api_user' do
  let(:title) { 'slave' }

  describe 'default params' do
    let(:params) {{ }}

    it 'should contain parent directory with correct props' do
      should contain_file('/var/lib/jenkins/users/slave').with(
        :ensure => 'directory',
        :owner  => 'jenkins',
        :mode   => '0640',
        :notify => 'Class[Jenkins::Service]'
      )
    end

    it 'should contain config file with correct props' do
      should contain_file('/var/lib/jenkins/users/slave/config.xml').with(
        :ensure  => 'present',
        :owner   => 'jenkins',
        :mode    => '0640',
        :replace => 'false',
        :notify  => 'Class[Jenkins::Service]'
      )
    end

    it 'should set fullName in config file' do
      should contain_file('/var/lib/jenkins/users/slave/config.xml').with_content(
        /^\s+<fullName>api_user: slave<\/fullName>$/
      )
    end
  end

  describe 'ensure absent' do
    let(:params) {{
      :ensure => 'absent',
    }}

    it { should contain_file('/var/lib/jenkins/users/slave').with_ensure('absent') }
    it { should contain_file('/var/lib/jenkins/users/slave/config.xml').with_ensure('absent') }
  end

  describe 'custom state directory' do
    let(:params) {{
      :users_dir => '/opt/jenkins/users',
    }}

    it { should contain_file('/opt/jenkins/users/slave') }
    it { should contain_file('/opt/jenkins/users/slave/config.xml') }
  end
end
