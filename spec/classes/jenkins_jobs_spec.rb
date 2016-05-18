require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'jobs' do
    context 'default' do
      it { should contain_class('jenkins::jobs') }
    end

    context 'with one job' do
      let(:params) { { :job_hash => { 'build' => { 'config' => '<xml/>' } } } }
      it { should contain_jenkins__job('build').with_config('<xml/>') }
    end

    context 'with cli disabled' do
      let(:params) do
        {
          :service_ensure => 'stopped',
          :cli => false,
          :job_hash => { 'build' => { 'config' => '<xml/>' } }
        }
      end
      it do
        expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /error during compilation/)
      end
    end

  end

end
