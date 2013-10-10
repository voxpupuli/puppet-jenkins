require 'spec_helper'

describe 'jenkins::repo::debian' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Debian', :lsbdistcodename => 'precise' } }

  describe 'default' do
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
  end

  describe 'lts = 1' do
    let(:pre_condition) { ['class jenkins { $lts = 1 }', 'include jenkins'] }
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
  end

end
