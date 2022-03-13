# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::sysconfig' do
  let(:pre_condition) { 'include jenkins' }
  let(:title) { 'myprop' }
  let(:params) { { 'value' => 'myvalue' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do # rubocop:todo RSpec/EmptyExampleGroup
      let(:facts) { os_facts }

      case os_facts[:os]['family']
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
