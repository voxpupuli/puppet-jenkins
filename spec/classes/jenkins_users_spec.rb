require 'spec_helper'

describe 'jenkins', type: :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  context 'users' do
    context 'default' do
      it { is_expected.to contain_class('jenkins::users') }
    end

    context 'with testuser' do
      let(:params) do
        { user_hash: { 'user' => {
          'email' => 'user@example.com',
          'password' => 'test'
        } } }
      end

      it { is_expected.to contain_jenkins__user('user').with_email('user@example.com').with_password('test') }
    end
  end
end
