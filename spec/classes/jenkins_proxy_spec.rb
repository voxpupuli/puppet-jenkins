require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'proxy' do
    context 'default' do
      it { should_not contain_class('jenkins::proxy') }
    end

    context 'with basic proxy config' do
      let(:params) { { :proxy_host => 'myhost', :proxy_port => 1234 } }
      it { should create_class('jenkins::proxy') }
      it do
        should contain_file('/var/lib/jenkins/proxy.xml').with(
          :owner => 'jenkins',
          :group => 'jenkins',
          :mode  => '0644',
        )
      end
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<name>myhost<\/name>/) }
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<port>1234<\/port>/) }
      it { should contain_file('/var/lib/jenkins/proxy.xml').without(:content => /<noProxyHost>/) }
    end

    context 'with "no_proxy_list" proxy config' do
      let(:params) { { :proxy_host => 'myhost', :proxy_port => 1234, :no_proxy_list => ['example.com','test.host.net'] } }
      it { should create_class('jenkins::proxy') }
      it do
        should contain_file('/var/lib/jenkins/proxy.xml').with(
          :owner => 'jenkins',
          :group => 'jenkins',
          :mode  => '0644',
        )
      end
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<name>myhost<\/name>/) }
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<port>1234<\/port>/) }
      it { should contain_file('/var/lib/jenkins/proxy.xml').with(:content => /<noProxyHost>example\.com\ntest\.host\.net<\/noProxyHost>/) }
    end
  end

end
