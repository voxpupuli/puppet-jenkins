require 'spec_helper'

describe 'jenkins', type: :class do
  describe 'repo' do
    describe 'default' do
      describe 'RedHat' do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'CentOs',
            operatingsystemrelease: '6.7',
            operatingsystemmajrelease: '6'
          }
        end

        it { is_expected.to contain_class('jenkins::repo::el') }
        it { is_expected.to_not contain_class('jenkins::repo::suse') }
        it { is_expected.to_not contain_class('jenkins::repo::debian') }
      end

      describe 'Suse' do
        let(:facts) { { osfamily: 'Suse', operatingsystem: 'OpenSuSE' } }

        it { is_expected.to contain_class('jenkins::repo::suse') }
        it { is_expected.to_not contain_class('jenkins::repo::el') }
        it { is_expected.to_not contain_class('jenkins::repo::debian') }
      end

      describe 'Debian' do
        let(:facts) do {
          osfamily: 'Debian',
          lsbdistid: 'debian',
          lsbdistcodename: 'natty',
          operatingsystem: 'Debian',
          os: {
            name: 'Debian',
            release: { full: '11.04' }
          }
        } end

        it { is_expected.to contain_class('jenkins::repo::debian') }
        it { is_expected.to_not contain_class('jenkins::repo::suse') }
        it { is_expected.to_not contain_class('jenkins::repo::el') }
      end

      describe 'Unknown' do
        let(:facts) { { osfamily: 'SomethingElse', operatingsystem: 'RedHat' } }

        it { expect { is_expected.to raise_error(Puppet::Error) } }
      end
    end

    describe 'repo => false' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'CentOs',
          operatingsystemrelease: '6.7',
          operatingsystemmajrelease: '6'
        }
      end
      let(:params) { { repo: false } }

      it { is_expected.to_not contain_class('jenkins::repo') }
      it { is_expected.to_not contain_class('jenkins::repo::el') }
      it { is_expected.to_not contain_class('jenkins::repo::suse') }
      it { is_expected.to_not contain_class('jenkins::repo::debian') }
    end
  end
end
