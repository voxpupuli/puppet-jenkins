require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'proxy' do
    context 'default' do
      it { should_not contain_class('jenkins::proxy') }
    end

    context 'with proxy config' do
      let(:params) { { :proxy_host => 'myhost', :proxy_port => 1234 } }
      it { should create_class('jenkins::proxy') }
      it { should contain_file('/var/lib/jenkins/proxy.xml') }
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<name>myhost<\/name>/) }
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<port>1234<\/port>/) }
    end
  end

end

