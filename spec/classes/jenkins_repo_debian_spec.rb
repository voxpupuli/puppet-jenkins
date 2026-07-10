# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}", if: os_facts[:osfamily] == 'Debian' do
      let(:facts) { os_facts }

      context 'repo::debian' do
        shared_examples 'an apt catalog' do
          it { is_expected.to contain_class('apt') }
          it { is_expected.to contain_apt__source('jenkins') }
        end

        describe 'default' do
          it_behaves_like 'an apt catalog'
          it do
            is_expected.to contain_apt__source('jenkins').with(
              location: 'https://pkg.jenkins.io/debian-stable',
              key: {
                'id' => '5E386EADB55F01504CAE8BCF7198F4B714ABFC68',
                'source' => 'https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key',
              },
            )
          end
        end

        describe 'lts = true' do
          let(:params) { { lts: true } }

          it_behaves_like 'an apt catalog'
          it { is_expected.to contain_apt__source('jenkins').with_location('https://pkg.jenkins.io/debian-stable') }
        end

        describe 'lts = false' do
          let(:params) { { lts: false } }

          it_behaves_like 'an apt catalog'
          it { is_expected.to contain_apt__source('jenkins').with_location('https://pkg.jenkins.io/debian') }
        end
      end
    end
  end
end
