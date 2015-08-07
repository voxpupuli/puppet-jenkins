require 'spec_helper'

describe 'jenkins::master' do

  let(:params) { { :version => '1.2.3' } }
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  it { should contain_jenkins__plugin('swarm').with_version('1.2.3') }

end
