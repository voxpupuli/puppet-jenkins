require 'spec_helper'

describe 'jenkins' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:pre_condition) { [] }

  context 'cli' do
    context 'default' do
      it { should_not contain_class('jenkins::cli') }
    end

    context '$cli => true' do
      let(:params) { { :cli => true } }
      it { should create_class('jenkins::cli') }
      it { should contain_exec('jenkins-cli') }
    end
  end

end
