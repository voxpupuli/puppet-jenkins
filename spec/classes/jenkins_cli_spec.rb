require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

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
