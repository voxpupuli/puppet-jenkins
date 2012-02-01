require 'spec_helper'

# Note, rspec-puppet determines the class name from the top level describe
# string.
describe 'jenkins' do
  it { should contain_class 'jenkins' }
  it { should contain_class 'jenkins::repo' }
  it { should contain_class 'jenkins::package' }
  it { should contain_class 'jenkins::service' }

  rpm_operatingsystems = [ "RedHat", "CentOS" ]
  deb_operatingsystems = [ "Ubuntu", "Debian" ]

  rpm_operatingsystems.each do |os|
    describe "on #{os}" do
      let(:facts) do
        { 'operatingsystem' => os }
      end
      it { should contain_class 'jenkins::repo::el' }
      it { should_not contain_class 'jenkins::repo::debian' }
    end
  end

  deb_operatingsystems.each do |os|
    describe "on #{os}" do
      let(:facts) do
        { 'operatingsystem' => os }
      end
      it { should contain_class 'jenkins::repo::debian' }
      it { should_not contain_class 'jenkins::repo::el' }
    end
  end
end
