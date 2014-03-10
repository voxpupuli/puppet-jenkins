require 'spec_helper'

describe 'jenkins', :type => :module do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Redhat', :operatingsystem => 'CentOS' } }

  context 'repo::el' do
    describe 'default' do
      it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat/') }
    end

    describe 'lts = true' do
      let(:params) { { :lts => true } }
      it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat-stable/') }
    end
  end

end
