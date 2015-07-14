require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'credentials' do
    context 'default' do
      it { should contain_class('jenkins::credentials') }
    end

    context 'with test credentials' do
      let(:params) {
        { :credential_hash => { 'github-deploy-key' => {
          'password' => 'test',
          'private_key_or_path' => 'KEYGOESHERE'
      } } } }
      it { should contain_jenkins__credential('github-deploy-key').with_password('test').with_private_key_or_path('KEYGOESHERE') }
    end

  end

end
