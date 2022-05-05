# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'plugins' do
        context 'default' do
          it { is_expected.to contain_class('jenkins::plugins') }
        end

        context 'install plugin' do
          let(:params) { { plugin_hash: { 'git' => { 'version' => '1.1.1' } } } }

          it { is_expected.to contain_jenkins__plugin('git').with_version('1.1.1') }
        end
      end
    end
  end
end
