require 'spec_helper'

describe 'jenkins::repo::el' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Redhat', :operatingsystem => 'CentOS' } }
  let(:pre_condition) { [] }

  describe 'default' do
    it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat/') }
  end

  describe 'lts = true' do
    let(:pre_condition) { ['class jenkins { $lts = true }', 'include jenkins'] }
    it { should contain_yumrepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/redhat-stable/') }
  end

end
