require 'spec_helper'

describe 'jenkins', type: :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  context 'jobs' do
    context 'default' do
      it { is_expected.to contain_class('jenkins::jobs') }
    end

    context 'with one job' do
      let(:params) { { job_hash: { 'build' => { 'config' => '<xml/>' } } } }

      it { is_expected.to contain_jenkins__job('build').with_config('<xml/>') }
    end

    context 'with cli disabled' do
      let(:params) do
        {
          service_ensure: 'stopped',
          cli: false,
          job_hash: { 'build' => { 'config' => '<xml/>' } }
        }
      end

      it { is_expected.to compile.and_raise_error(%r{Management of Jenkins jobs requires \\\$jenkins::service_ensure to be set to 'running'}) }
    end
  end
end
