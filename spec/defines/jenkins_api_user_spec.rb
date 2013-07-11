require 'spec_helper'

describe 'jenkins::api_user' do
  let(:title) { 'slave' }

  describe 'required params not passed' do
    let(:params) {{ }}

    it { expect { should }.to raise_error(Puppet::Error, /^Must pass token_hash /) }
  end

  describe 'default params' do
    let(:params) {{
      :token_hash => 'mekmitasdigoat',
    }}

    it 'should contain parent directory with correct props' do
      should contain_file('/var/lib/jenkins/users/slave').with(
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :notify => 'Class[Jenkins::Service]'
      )
    end

    it 'should contain config file with correct props' do
      should contain_file('/var/lib/jenkins/users/slave/config.xml').with(
        :ensure  => 'present',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        :notify  => 'Class[Jenkins::Service]',
        :content => /^\s+<apiToken>mekmitasdigoat<\/apiToken>$/
      )
    end

    it 'should set fullName in config file' do
      should contain_file('/var/lib/jenkins/users/slave/config.xml').with_content(
        /^\s+<fullName>slave<\/fullName>$/
      )
    end

    it 'should set apiToken in config file' do
      should contain_file('/var/lib/jenkins/users/slave/config.xml').with_content(
        /^\s+<apiToken>mekmitasdigoat<\/apiToken>$/
      )
    end
  end

  describe 'ensure absent' do
    let(:params) {{
      :ensure     => 'absent',
      :token_hash => 'mekmitasdigoat',
    }}

    it { should contain_file('/var/lib/jenkins/users/slave').with_ensure('absent') }
    it { should contain_file('/var/lib/jenkins/users/slave/config.xml').with_ensure('absent') }
  end

  describe 'custom state directory' do
    let(:params) {{
      :token_hash => 'mekmitasdigoat',
      :users_dir  => '/opt/jenkins/users',
    }}

    it { should contain_file('/opt/jenkins/users/slave') }
    it { should contain_file('/opt/jenkins/users/slave/config.xml') }
  end
end
