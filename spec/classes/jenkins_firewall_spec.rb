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
  let(:pre_condition) { ['define firewall($action, $state, $dport, $proto) {}'] }
  let(:params) { { configure_firewall: true } }

  context 'firewall' do
    it { is_expected.to contain_firewall('500 allow Jenkins inbound traffic') }
  end
end
