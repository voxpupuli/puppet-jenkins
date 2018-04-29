require 'spec_helper'

describe 'jenkins::user', type: :define do
  let(:title) { 'foo' }

  let :pre_condition do
    'include jenkins'
  end

  on_supported_os.each do |os, facts|
    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      describe 'relationships' do
        let(:params) { { email: 'foo@example.org', password: 'foo' } }

        it do
          is_expected.to contain_jenkins__user('foo').
            that_requires('Class[jenkins::cli_helper]')
        end
        it do
          is_expected.to contain_jenkins__user('foo').
            that_comes_before('Anchor[jenkins::end]')
        end
      end
    end
  end
end
