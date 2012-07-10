require 'spec_helper'

# Note, rspec-puppet determines the class name from the top level describe
# string.
describe 'jenkins' do
  describe "on RedHat" do
    let(:facts) do
      { :osfamily => 'RedHat' }
    end
    it { should contain_class 'jenkins' }
    it { should contain_class 'jenkins::repo' }
    it { should contain_class 'jenkins::package' }
    it { should contain_class 'jenkins::service' }
    it { should contain_class 'jenkins::repo::el' }
    it { should_not contain_class 'jenkins::repo::debian' }
  end

  let(:facts) do
    { :osfamily => 'Debian' }
  end
  let :pre_condition do
    " define apt::source (
        $location          = '',
        $release           = $lsbdistcodename,
        $repos             = 'main',
        $include_src       = true,
        $required_packages = false,
        $key               = false,
        $key_server        = 'keyserver.ubuntu.com',
        $key_content       = false,
        $key_source        = false,
        $pin               = false
      ) {
        notify { 'mock apt::source $title':; }
      }
    "
  end

  describe "on Debian" do
    it { should contain_class 'jenkins' }
    it { should contain_class 'jenkins::repo' }
    it { should contain_class 'jenkins::package' }
    it { should contain_class 'jenkins::service' }
    it { should contain_class 'jenkins::repo::debian' }
    it { should_not contain_class 'jenkins::repo::el' }
  end
end
