require 'spec_helper'

describe 'jenkins::plugin' do
  let(:title) { 'myplug' }

  shared_examples 'manages plugins dirs' do
    it { should contain_file('/var/lib/jenkins') }
    it { should contain_file('/var/lib/jenkins/plugins') }
  end

  include_examples 'manages plugins dirs'
  it { should contain_group('jenkins') }
  it { should contain_user('jenkins').with('home' => '/var/lib/jenkins') }

  context 'with my plugin parent directory already defined' do
    let(:pre_condition) do
      [
        "file { '/var/lib/jenkins' : ensure => directory, }",
      ]
    end

    include_examples 'manages plugins dirs'
  end


  describe 'without version' do
    it { should contain_exec('download-myplug').with(
      :command      => 'rm -rf myplug myplug.hpi myplug.jpi && wget --no-check-certificate http://updates.jenkins-ci.org/latest/myplug.hpi',
      :environment  => nil
    )}
    it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with version' do
    let(:params) { { :version => '1.2.3' } }

    it { should contain_exec('download-myplug').with(
      :command      => 'rm -rf myplug myplug.hpi myplug.jpi && wget --no-check-certificate http://updates.jenkins-ci.org/download/plugins/myplug/1.2.3/myplug.hpi',
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


  describe 'with a custom update center' do
    shared_examples 'execute the right fetch command' do
      it 'should wget the plugin' do
        expect(subject).to contain_exec('download-git').with({
          :command => "rm -rf git git.hpi git.jpi && wget --no-check-certificate #{expected_url}",
        })
      end
    end

    let(:title) { 'git' }

    context 'by default' do
      context 'with a version' do
        let(:version) { '1.3.3.7' }
        let(:params) { {:version => version} }
        let(:expected_url) do
          "http://updates.jenkins-ci.org/download/plugins/#{title}/#{version}/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end

      context 'without a version' do
        let(:expected_url) do
          "http://updates.jenkins-ci.org/latest/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end
    end

    context 'with a custom update_url' do
      let(:update_url) { 'http://rspec' }

      context 'without a version' do
        let(:params) { {:update_url => update_url} }
        let(:expected_url) do
          "#{update_url}/latest/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end

      context 'with a version' do
        let(:version) { '1.2.3' }
        let(:params) { {:update_url => update_url, :version => version} }
        let(:expected_url) do
          "#{update_url}/download/plugins/#{title}/#{version}/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end
    end
  end

end
