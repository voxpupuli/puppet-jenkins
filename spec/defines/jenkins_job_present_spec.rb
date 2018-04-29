require 'spec_helper'

describe 'jenkins::job::present' do
  let(:title) { 'myjob' }

  let :pre_condition do
    'include jenkins; include jenkins::cli'
  end

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      describe 'with defaults' do
        it 'fails' do
          is_expected.to raise_error(Puppet::Error, %r{Please set one of})
        end
      end

      describe 'with both_config_and_config_file_set' do
        quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
        let(:params) { { config: quotes, config_file: quotes } }

        it 'fails' do
          is_expected.to raise_error(Puppet::Error, %r{You cannot set both})
        end
      end

      describe 'with config_file set' do
        let(:config_file) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
        let(:params) { { config_file: config_file } }

        it { is_expected.to contain_exec('jenkins create-job myjob') }
        it { is_expected.to contain_exec('jenkins update-job myjob') }
        it { is_expected.not_to contain_exec('jenkins delete-job myjob') }
      end
    end
  end
end
