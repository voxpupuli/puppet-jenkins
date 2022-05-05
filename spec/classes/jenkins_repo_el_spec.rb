# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins' do
  on_supported_os(supported_os: [{ 'operatingsystem' => 'CentOS' }]).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'repo::el' do
        describe 'default' do
          it { is_expected.to contain_yumrepo('jenkins').with_baseurl('https://pkg.jenkins.io/redhat-stable/') }
          it { is_expected.to contain_yumrepo('jenkins').with_proxy(nil) }
        end

        describe 'lts = true' do
          let(:params) { { lts: true } }

          it { is_expected.to contain_yumrepo('jenkins').with_baseurl('https://pkg.jenkins.io/redhat-stable/') }
          it { is_expected.to contain_yumrepo('jenkins').with_proxy(nil) }
        end

        describe 'lts = false' do
          let(:params) { { lts: false } }

          it { is_expected.to contain_yumrepo('jenkins').with_proxy(nil) }
          it { is_expected.to contain_yumrepo('jenkins').with_baseurl('https://pkg.jenkins.io/redhat/') }
        end

        describe 'repo_proxy is set' do
          let(:params) { { repo_proxy: 'http://proxy:8080/' } }

          it { is_expected.to contain_yumrepo('jenkins').with_proxy('http://proxy:8080/') }
        end
      end
    end
  end
end
