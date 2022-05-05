# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::user', type: :define do
  let(:title) { 'foo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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
