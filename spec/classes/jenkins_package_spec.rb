# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'package' do
        context 'default' do
          it { is_expected.to contain_package('jenkins').with_installed }
        end

        context 'with version' do
          let(:params) { { version: '1.2.3' } }

          it { is_expected.to contain_package('jenkins').with_ensure('1.2.3') }
        end
      end
    end
  end
end
