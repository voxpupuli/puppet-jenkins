require 'spec_helper'

describe 'jenkins::plugin' do
  let(:title) { 'myplug' }

  it { should contain_file('/var/lib/jenkins') }
  it { should contain_file('/var/lib/jenkins/plugins') }
  it { should contain_group('jenkins') }
  it { should contain_user('jenkins').with('home' => '/var/lib/jenkins') }

  describe 'without version' do
    it { should contain_exec('download-myplug').with(
      :command      => 'rm -rf myplug myplug.* && wget --no-check-certificate http://updates.jenkins-ci.org/latest/myplug.hpi',
      :environment  => nil
    )}
    it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with version' do
    let(:params) { { :version => '1.2.3' } }

    it { should contain_exec('download-myplug').with(
      :command      => 'rm -rf myplug myplug.* && wget --no-check-certificate http://updates.jenkins-ci.org/download/plugins/myplug/1.2.3/myplug.hpi',
      :environment  => nil
    ) }
    it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with version and in middle of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    let(:facts) { { :jenkins_plugins => 'myplug 1.2.3, fooplug 1.4.5' } }

    it { should_not contain_exec('download-myplug') }
    it { should_not contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with version and at end of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    let(:facts) { { :jenkins_plugins => 'fooplug 1.4.5, myplug 1.2.3' } }

    it { should_not contain_exec('download-myplug') }
    it { should_not contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with proxy' do
    let(:pre_condition) { [
      'class jenkins {
        $proxy_host = "proxy.company.com"
        $proxy_port = 8080
      }',
      'include jenkins'
    ]}

    it { should contain_exec('download-myplug').with(:environment => ["http_proxy=proxy.company.com:8080", "https_proxy=proxy.company.com:8080"]) }
  end

end
