require 'spec_helper'

describe 'jenkins::repo::debian' do

  # Switching OS Family to prevent duplicate declaration
  let(:facts) do
    {
      :osfamily => 'Ubuntu',
      :lsbdistcodename => 'precise',
      :lsbdistid => 'ubuntu'
    }
  end

  describe 'default' do
    let(:pre_condition) { [] }
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian') }
  end

  describe 'lts = true' do
    let(:pre_condition) { ['class jenkins { $lts = true }', 'include jenkins'] }
    it { should contain_apt__source('jenkins').with_location('http://pkg.jenkins-ci.org/debian-stable') }
  end
end
