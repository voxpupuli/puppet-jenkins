require 'spec_helper'

describe 'jenkins::repo::suse' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Debian' } }

  it { should include_class('jenkins::repo') }

  describe 'default' do
    it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse/') }
  end

  describe 'lts = 1' do
    let(:params) { { :lts => 1 } }
    it { should contain_zypprepo('jenkins').with_baseurl('http://pkg.jenkins-ci.org/opensuse-stable/') }
  end

end
