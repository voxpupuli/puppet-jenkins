require 'spec_helper'

describe 'jenkins::repo::debian' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'RedHat' } }

  it { should include_class('jenkins::repo') }

  describe 'default' do
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
  end

  describe 'lts = 1' do
    let(:params) { { :lts => 1 } }
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
  end

end
