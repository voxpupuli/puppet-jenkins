require 'spec_helper'

describe 'jenkins::sysconfig' do
  let(:pre_condition) { 'include ::jenkins' }

  let(:title) { 'myprop' }
  let(:params) { { 'value' => 'myvalue' } }

  describe 'on RedHat' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'CentOS',
        operatingsystemrelease: '7.2',
        operatingsystemmajrelease: '7'
      }
    end

    it do
      is_expected.to contain_file_line('Jenkins sysconfig setting myprop').with(
        path: '/etc/sysconfig/jenkins',
        line: 'myprop="myvalue"',
        match: '^myprop='
      ).that_notifies('Service[jenkins]')
    end
  end # on RedHat

  describe 'on Debian' do
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Debian',
        lsbdistcodename: 'squeeze',
        lsbdistid: 'debian',
        os: {
          name: 'Debian',
          release: { full: '11.04' }
        }
      }
    end

    it do
      is_expected.to contain_file_line('Jenkins sysconfig setting myprop').with(
        path: '/etc/default/jenkins',
        line: 'myprop="myvalue"',
        match: '^myprop='
      ).that_notifies('Service[jenkins]')
    end
  end # on Debian
end
