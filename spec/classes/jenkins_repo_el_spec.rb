require 'spec_helper'

describe 'jenkins::repo::el' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Redhat', :operatingsystem => 'CentOS' } }

  describe 'default' do
    it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat/') }
  end

  describe 'lts = 1' do
    let(:pre_condition) { ['class jenkins { $lts = 1 }', 'include jenkins'] }
    it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat-stable/') }
  end

end
