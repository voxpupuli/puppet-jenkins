require 'spec_helper'

describe 'jenkins::repo::debian' do
  # Switching OS Family to prevent duplicate declaration
  let(:facts) { { :osfamily => 'Debian', :lsbdistcodename => 'precise' } }

  describe 'default' do
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
  end

  describe 'lts = true' do
    let(:pre_condition) { ['class jenkins { $lts_real = true }', 'include jenkins'] }
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
  end

end
