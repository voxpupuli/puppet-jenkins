# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::security' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { { security_model: 'test' } }

      describe 'relationships' do
        it do
          is_expected.to contain_class('jenkins::security').
            that_requires('Class[jenkins::cli_helper]')
        end

        it do
          is_expected.to contain_class('jenkins::security').
            that_comes_before('Anchor[jenkins::end]')
        end

        it { is_expected.to compile }
      end
    end
  end
end
