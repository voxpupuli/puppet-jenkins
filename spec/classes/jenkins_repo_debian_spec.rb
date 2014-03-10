require 'spec_helper'

describe 'jenkins', :type => :module do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) do
    {
      :osfamily => 'Debian',
      :lsbdistcodename => 'precise',
      :lsbdistid => 'ubuntu',
      :operatingsystem => 'Debian'
    }
  end

  context 'repo::debian' do
    describe 'default' do
      it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
    end

    describe 'lts = true' do
      let(:params) { { :lts => true } }
      it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
    end
  end
end
