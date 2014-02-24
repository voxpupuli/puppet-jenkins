require 'spec_helper'

describe 'jenkins::repo::suse' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Suse' } }

  describe 'default' do
    it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse/') }
  end

  describe 'lts = true' do
    let(:pre_condition) { ['class jenkins { $lts = true }', 'include jenkins'] }
    it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse-stable/') }
  end

end
