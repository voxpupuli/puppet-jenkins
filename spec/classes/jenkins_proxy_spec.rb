require 'spec_helper'

describe 'jenkins', type: :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  context 'proxy' do
    context 'default' do
      it { is_expected.to contain_class('jenkins::proxy') }
    end

    context 'with basic proxy config' do
      let(:params) { { proxy_host: 'myhost', proxy_port: 1234 } }

      it { is_expected.to create_class('jenkins::proxy') }
      it do
        is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(
          owner: 'jenkins',
          group: 'jenkins',
          mode: '0644'
        )
      end
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(content: %r{<name>myhost</name>}) }
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(content: %r{<port>1234</port>}) }
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').without(content: %r{<noProxyHost>}) }
    end

    context 'with "no_proxy_list" proxy config' do
      let(:params) { { proxy_host: 'myhost', proxy_port: 1234, no_proxy_list: ['example.com', 'test.host.net'] } }

      it { is_expected.to create_class('jenkins::proxy') }
      it do
        is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(
          owner: 'jenkins',
          group: 'jenkins',
          mode: '0644'
        )
      end
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(content: %r{<name>myhost</name>}) }
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(content: %r{<port>1234</port>}) }
      it { is_expected.to contain_file('/var/lib/jenkins/proxy.xml').with(content: %r{<noProxyHost>example\.com\ntest\.host\.net</noProxyHost>}) }
    end
  end
end
