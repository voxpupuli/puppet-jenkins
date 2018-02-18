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
  let(:params) { { direct_download: 'http://local.space/jenkins.rpm' } }

  describe 'direct_download' do
    context 'default' do
      it { is_expected.to contain_package('jenkins').with_installed }
      it { is_expected.not_to contain_class('jenkins::package') }
      it { is_expected.to contain_class('jenkins::direct_download') }
    end

    context 'with version' do
      let(:params) { { version: '1.2.3' } }

      it { is_expected.to contain_package('jenkins').with_ensure('1.2.3') }
    end

    context 'package dir created' do
      it { is_expected.to contain_file('/var/cache/jenkins_pkgs').with_ensure('directory') }
    end

    context 'staging resource created' do
      it do
        is_expected.to contain_archive('jenkins.rpm').with(
          source: 'http://local.space/jenkins.rpm',
          path: '/var/cache/jenkins_pkgs/jenkins.rpm',
          cleanup: false,
          extract: false
        ).that_comes_before('Package[jenkins]')
      end
    end

    context 'package removable' do
      let(:params) { { version: 'absent', direct_download: 'http://local.space/jenkins.rpm' } }

      it { is_expected.not_to contain_staging__file('jenkins.rpm') }
      it { is_expected.to contain_package('jenkins').with_ensure('absent') }
    end

    context 'unsupported provider fails' do
      let(:params) { { package_provider: false, direct_download: 'http://local.space/jenkins.rpm' } }

      it do
        expect { is_expected.to compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError, %r{error during compilation})
      end
    end
  end
end
