# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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
  end
end
