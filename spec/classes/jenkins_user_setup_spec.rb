# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'user_setup' do
        context 'default' do
          it { is_expected.to contain_user('jenkins') }
          it { is_expected.to contain_group('jenkins') }

          [
            '/var/lib/jenkins',
            '/var/lib/jenkins/plugins',
            '/var/lib/jenkins/jobs'
          ].each do |datadir|
            it do
              is_expected.to contain_file(datadir).with(
                ensure: 'directory',
                mode: '0755',
                group: 'jenkins',
                owner: 'jenkins'
              )
            end
          end
        end

        context 'unmanaged' do
          let(:params) do
            {
              manage_user: false,
              manage_group: false,
              manage_datadirs: false
            }
          end

          it { is_expected.not_to contain_user('jenkins') }
          it { is_expected.not_to contain_group('jenkins') }
          it { is_expected.not_to contain_file('/var/lib/jenkins') }
          it { is_expected.not_to contain_file('/var/lib/jenkins/jobs') }
          it { is_expected.not_to contain_file('/var/lib/jenkins/plugins') }
        end

        context 'custom home' do
          let(:params) do
            {
              localstatedir: '/custom/jenkins'
            }
          end

          it { is_expected.to contain_user('jenkins').with_home('/custom/jenkins') }
          it { is_expected.to contain_file('/custom/jenkins') }
          it { is_expected.to contain_file('/custom/jenkins/plugins') }
          it { is_expected.to contain_file('/custom/jenkins/jobs') }
        end
      end
    end
  end
end
