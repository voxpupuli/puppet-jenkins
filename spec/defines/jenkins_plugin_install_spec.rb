require 'spec_helper'

# Note, rspec-puppet determines the define name from the top level describe
# string.
describe 'jenkins::plugin::install' do
  let(:title) { 'git' }
  it { should contain_user('jenkins') }
  it { should contain_group('jenkins') }
  it { should contain_file('/var/lib/jenkins') }
  it { should contain_file('/var/lib/jenkins/plugins') }
  it { should contain_exec('download-git') }
end

