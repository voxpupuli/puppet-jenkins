require 'spec_helper'

# Note, rspec-puppet determines the class name from the top level describe
# string.
describe 'jenkins', :type => :module do
  describe "on RedHat" do
    let(:facts) do
      { :osfamily => 'RedHat', :operatingsystem => 'CentOS' }
    end

    describe 'default' do
      it { should contain_class 'jenkins' }
      it { should contain_class 'java' }
      it { should contain_class 'jenkins::package' }
      it { should contain_class 'jenkins::config' }
      it { should contain_class 'jenkins::plugins' }
      it { should contain_class 'jenkins::service' }
      it { should_not contain_class 'jenkins::firewall' }
      it { should_not contain_class 'jenkins::proxy' }
      it { should contain_class 'jenkins::repo' }
      it { should contain_class 'jenkins::repo::el' }
      it { should_not contain_class 'jenkins::repo::debian' }
      it { should_not contain_class 'jenkins::repo::suse' }
    end

    describe 'without java' do
      let(:params) { { :install_java => false } }
      it { should_not contain_class 'java' }
    end

    describe 'without repo' do
      let(:params) { { :repo => false } }
      it { should_not contain_class 'jenkins::repo' }
    end

    describe 'with java_package_name' do
      let(:params) { { :java_package_name => 'java-1.7.0-openjdk.x86_64' } }
      it { should contain_class('java').with({'name' => 'java-1.7.0-openjdk.x86_64'}) }
    end

    describe 'with only proxy host' do
      let(:params) { { :proxy_host => '1.2.3.4' } }
      it { should_not contain_class('jenkins::proxy') }
    end

    describe 'with only proxy_port' do
      let(:params) { { :proxy_port => 1234 } }
      it { should_not contain_class('jenkins::proxy') }
    end

    describe 'with proxy_host and proxy_port' do
      let(:params) { { :proxy_host => '1.2.3.4', :proxy_port => 1234 } }
      it { should contain_class 'jenkins::proxy'}
    end

    describe 'with firewall, configure_firewall => true' do
      let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
      let(:params) { { :configure_firewall => true } }
      it { should contain_class 'jenkins::firewall' }
    end

    describe 'with firewall, configure_firewall => false' do
      let(:pre_condition) { ['define firewall ($action, $state, $dport, $proto) {}'] }
      let(:params) { { :configure_firewall => false } }
      it { should_not contain_class 'jenkins::firewall' }
    end

    describe 'with firewall, configure_firewall unset' do
      let(:pre_condition) { 'define firewall ($action, $state, $dport, $proto) {}' }
      it { expect { should raise_error(Puppet::Error) } }
    end

    describe 'executors =>' do
      context 'undef' do
        it { should_not contain_class('jenkins::cli_helper') }
        it { should_not contain_jenkins__cli__exec('set_num_executors') }
      end

      context '42' do
        let(:params) {{ :executors => 42 }}

        it { should contain_class('jenkins::cli_helper') }
        it do
          should contain_jenkins__cli__exec('set_num_executors').with(
            :command => ['set_num_executors', 42],
            :unless  => '[ $($HELPER_CMD get_num_executors) -eq 42 ]',
          )
        end
        it { should contain_jenkins__cli__exec('set_num_executors').that_requires('Class[jenkins::cli]') }
        it { should contain_jenkins__cli__exec('set_num_executors').that_comes_before('Class[jenkins::jobs]') }
      end

      context '{}' do
        let(:params) {{ :executors => {} }}

        it 'should fail' do
          should raise_error(Puppet::Error, /to be an Integer/)
        end
      end
    end # executors =>
  end
end
