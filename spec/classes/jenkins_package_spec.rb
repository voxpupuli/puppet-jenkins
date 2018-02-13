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

  describe 'package' do
    context 'default' do
      it { is_expected.to contain_package('jenkins').with_installed }
    end

    context 'with version' do
      let(:params) { { version: '1.2.3' } }

      it { is_expected.to contain_package('jenkins').with_ensure('1.2.3') }
    end
  end
end
