# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins_port' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        let(:pre_condition) do
          'include jenkins'
        end

        it 'defaults to 8080' do
          is_expected.to run.with_params.and_return(8080)
        end
      end

      context 'with overwritten configuration' do
        let(:pre_condition) do
          <<-ENDPUPPET
          class { 'jenkins':
            config_hash => {'JENKINS_PORT' => {'value' => '1337'}},
          }
          ENDPUPPET
        end

        it 'is our overwritten port' do
          is_expected.to run.with_params.and_return('1337')
        end
      end
    end
  end
end
