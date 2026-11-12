# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { configure_firewall: true } }

      context 'firewall' do
        it { is_expected.to contain_firewall('500 allow Jenkins inbound traffic') }
      end
    end
  end
end
