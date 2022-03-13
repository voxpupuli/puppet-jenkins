# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::job::present' do
  let(:title) { 'myjob' }
  let(:pre_condition) do
    "class { 'jenkins': cli => true, }"
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.and_raise_error(%r{Please set one of}) }

      describe 'with both_config_and_config_file_set' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { config: quotes, config_file: quotes } }

        it { is_expected.to compile.and_raise_error(%r{You cannot set both}) }
      end

      describe 'with config_file set' do
        let(:config_file) { File.expand_path(File.join(__dir__, '..', 'fixtures', 'testjob.xml')) }
        let(:params) { { config_file: config_file } }

        it { is_expected.to contain_exec('jenkins create-job myjob') }
        it { is_expected.to contain_exec('jenkins update-job myjob') }
        it { is_expected.not_to contain_exec('jenkins delete-job myjob') }
      end
    end
  end
end
