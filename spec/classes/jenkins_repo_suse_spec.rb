require 'spec_helper'

describe 'jenkins', type: :class do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { osfamily: 'Suse', operatingsystem: 'OpenSuSE' } }

  context 'repo::suse' do
    describe 'default' do
      it { is_expected.to contain_zypprepo('jenkins').with_baseurl('https://pkg.jenkins.io/opensuse-stable/') }
    end

    describe 'lts = true' do
      let(:params) { { lts: true } }

      it { is_expected.to contain_zypprepo('jenkins').with_baseurl('https://pkg.jenkins.io/opensuse-stable/') }
    end

    describe 'lts = false' do
      let(:params) { { lts: false } }

      it { is_expected.to contain_zypprepo('jenkins').with_baseurl('https://pkg.jenkins.io/opensuse/') }
    end
  end
end
