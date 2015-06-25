require 'spec_helper'

describe 'jenkins', :type => :module do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Redhat', :operatingsystem => 'CentOS' } }

  context 'repo::el' do
    describe 'default' do
      it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat/') }
      it { should contain_yumrepo('jenkins').with_proxy(nil) }
    end

    describe 'lts = true' do
      let(:params) { { :lts => true } }
      it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat-stable/') }
      it { should contain_yumrepo('jenkins').with_proxy(nil) }
    end

    describe 'repo_proxy is set' do
      let(:params) { { :repo_proxy => 'http://proxy:8080/' }}
      it { should contain_yumrepo('jenkins').with_proxy('http://proxy:8080/') }
    end
  end

end
