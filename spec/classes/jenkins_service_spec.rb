require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'service' do
    context 'default' do
      it { should contain_service('jenkins').with(:ensure => 'running', :enable => true) }
    end

    context 'managing service' do
      let(:params) { { :service_ensure => 'stopped', :service_enable => false } }
      it { should contain_service('jenkins').with(:ensure => 'stopped', :enable => false ) }
    end
  end

end
