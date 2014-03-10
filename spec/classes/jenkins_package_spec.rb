require 'spec_helper'

describe 'jenkins' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { [] }

  describe 'package' do
    context 'default' do
      it { should contain_package('jenkins').with_installed }
    end

    context 'with version' do
      let(:params) { { :version => '1.2.3' } }
      it { should contain_package('jenkins').with_ensure('1.2.3') }
    end
  end

end
