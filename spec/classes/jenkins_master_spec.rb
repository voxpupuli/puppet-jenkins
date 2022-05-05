# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { version: '1.2.3' } }
      let(:pre_condition) { 'include jenkins' }

      it { is_expected.to contain_jenkins__plugin('swarm').with_version('1.2.3') }
    end
  end
end
