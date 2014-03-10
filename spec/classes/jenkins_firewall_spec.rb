require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { ["define firewall($action, $state, $dport, $proto) {}"] }
  let(:params) { { :configure_firewall => true } }

  context 'firewall' do
    it { should contain_firewall('500 allow Jenkins inbound traffic') }
  end

end
