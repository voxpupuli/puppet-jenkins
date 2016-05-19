require 'spec_helper'

describe 'jenkins::job::present' do
  let(:title) { 'myjob' }
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  describe 'with defaults' do
    it 'should fail' do
      should raise_error(Puppet::Error, /Please set one of/)
    end
  end

  describe 'with both_config_and_config_file_set' do
    quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
    let(:params) {{ :config => quotes, :config_file => quotes }}
    it 'should fail' do
      should raise_error(Puppet::Error, /You cannot set both/)
    end
  end

  describe 'with config_file set' do
    let(:config_file) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/testjob.xml') }
    let(:params) {{ :config_file => config_file }}
    it { should contain_exec('jenkins create-job myjob').with_require('File[' + config_file + ']') }
    it { should contain_exec('jenkins update-job myjob') }
    it { should_not contain_exec('jenkins delete-job myjob') }
  end

end
