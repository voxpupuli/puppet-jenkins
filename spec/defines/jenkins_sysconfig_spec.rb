require 'spec_helper'

describe 'jenkins::sysconfig' do
  let(:pre_condition) { 'include jenkins' }

  let(:title) { 'myprop' }

  let(:params) { { 'value' => 'myvalue' } }
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      case facts[:os]['family']
      when 'RedHat'
        describe 'on RedHat' do
          it do
            is_expected.to contain_file_line('Jenkins sysconfig setting myprop').with(
              path: '/etc/sysconfig/jenkins',
              line: 'myprop="myvalue"',
              match: '^myprop='
            ).that_notifies('Service[jenkins]')
          end
        end
      when 'Debian'
        describe 'on Debian' do
          it do
            is_expected.to contain_file_line('Jenkins sysconfig setting myprop').with(
              path: '/etc/default/jenkins',
              line: 'myprop="myvalue"',
              match: '^myprop='
            ).that_notifies('Service[jenkins]')
          end
        end
      end
    end
  end
end
