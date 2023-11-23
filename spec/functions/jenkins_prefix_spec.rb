# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins_prefix' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        let(:pre_condition) do
          'include jenkins'
        end

        it { is_expected.to run.with_params.and_return('') }
      end

      context 'with overwritten configuration' do
        let(:pre_condition) do
          <<-ENDPUPPET
          class { 'jenkins':
            config_hash => {'PREFIX' => {'value' => '/test'}},
          }
          ENDPUPPET
        end

        it { is_expected.to run.with_params.and_return('/test') }
      end
    end
  end
end
