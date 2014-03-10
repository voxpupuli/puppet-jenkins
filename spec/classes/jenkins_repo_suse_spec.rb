require 'spec_helper'

describe 'jenkins', :type => :module do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Suse', :operatingsystem => 'OpenSuSE' } }

  context 'repo::suse' do
    describe 'default' do
      it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse/') }
    end

    describe 'lts = true' do
      let(:params) { { :lts => true } }
      it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse-stable/') }
    end
  end

end
