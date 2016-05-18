require 'spec_helper'

describe 'jenkins', :type => :module do

  describe 'repo' do
    describe 'default' do
      describe 'RedHat' do
        let(:facts) do
          {
            :osfamily                  => 'RedHat',
            :operatingsystem           => 'CentOs',
            :operatingsystemrelease    => '6.7',
            :operatingsystemmajrelease => '6',
          }
        end
        it { should contain_class('jenkins::repo::el') }
        it { should_not contain_class('jenkins::repo::suse') }
        it { should_not contain_class('jenkins::repo::debian') }
      end

      describe 'Linux' do
        let(:facts) { { :osfamily => 'Linux' } }
        let(:params) { { :install_java => false } }
        it { should contain_class('jenkins::repo::el') }
        it { should_not contain_class('jenkins::repo::suse') }
        it { should_not contain_class('jenkins::repo::debian') }
      end

      describe 'Suse' do
        let(:facts) { { :osfamily => 'Suse', :operatingsystem => 'OpenSuSE' } }
        it { should contain_class('jenkins::repo::suse') }
        it { should_not contain_class('jenkins::repo::el') }
        it { should_not contain_class('jenkins::repo::debian') }
      end

      describe 'Debian' do
        let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'debian', :lsbdistcodename => 'natty', :operatingsystem => 'Debian' } }
        it { should contain_class('jenkins::repo::debian') }
        it { should_not contain_class('jenkins::repo::suse') }
        it { should_not contain_class('jenkins::repo::el') }
      end

      describe 'Unknown' do
        let(:facts) { { :osfamily => 'SomethingElse', :operatingsystem => 'RedHat' } }
        it { expect { should raise_error(Puppet::Error) } }
      end
    end

    describe 'repo => false' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystem           => 'CentOs',
          :operatingsystemrelease    => '6.7',
          :operatingsystemmajrelease => '6',
        }
      end
      let(:params) { { :repo => false } }
      it { should_not contain_class('jenkins::repo') }
      it { should_not contain_class('jenkins::repo::el') }
      it { should_not contain_class('jenkins::repo::suse') }
      it { should_not contain_class('jenkins::repo::debian') }
    end
  end
end
