require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'users' do
    context 'default' do
      it { should contain_class('jenkins::users') }
    end

    context 'install user' do
      let(:params) { { :user_hash => { 'test' => { 'email' => 'test@testmail.com', 'password' => 'testpass' } } } }

      it { should contain_jenkins__user('test').with_email('test@testmail.com').with_password('testpass') }

    end
  end

end


