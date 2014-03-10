require 'spec_helper'

describe 'jenkins' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { [] }

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
