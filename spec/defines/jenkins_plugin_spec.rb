require 'spec_helper'

# Note, rspec-puppet determines the define name from the top level describe
# string.
describe 'jenkins::plugin' do
  let(:title) { 'git' }

  describe "on RedHat" do
    let(:facts) do
      { :osfamily => 'RedHat' }
    end
    it { should contain_user('jenkins') }
    it { should contain_group('jenkins') }
    it { should contain_file('/var/lib/jenkins') }
    it { should contain_file('/var/lib/jenkins/plugins') }
    it { should contain_exec('download-git') }
  end
  describe "on Debian" do
    let(:facts) do
      { :osfamily => 'Debian' }
    end
    it { should contain_user('jenkins') }
    it { should contain_group('jenkins') }
    it { should contain_file('/var/lib/jenkins') }
    it { should contain_file('/var/lib/jenkins/plugins') }
    it { should contain_exec('download-git') }
  end
end

