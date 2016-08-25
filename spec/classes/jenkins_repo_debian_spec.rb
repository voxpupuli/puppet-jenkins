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
    shared_examples 'an apt catalog' do
      it { should contain_class('apt') }
    end

    describe 'default' do
      it_behaves_like 'an apt catalog'
      it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
    end

    describe 'lts = true' do
      let(:params) { { :lts => true } }
      it_behaves_like 'an apt catalog'
      it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
    end

    describe 'lts = false' do
      let(:params) { { :lts => false } }
      it_behaves_like 'an apt catalog'
      it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
    end
  end
end
