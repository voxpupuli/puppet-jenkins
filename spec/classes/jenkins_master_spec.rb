require 'spec_helper'

describe 'jenkins::master' do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'CentOS' }}

  let(:params) { { :version => '1.2.3' } }
  it { should contain_jenkins__plugin('swarm').with_version('1.2.3') }

end
