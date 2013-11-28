require 'spec_helper'

describe 'jenkins::plugin' do
  let(:title) { 'myplug' }

  it { should contain_file('/var/lib/jenkins') }
  it { should contain_file('/var/lib/jenkins/plugins') }
  it { should contain_group('jenkins') }
  it { should contain_user('jenkins') }

  describe 'without version' do
    it { should contain_exec('download-myplug').with_command('wget --no-check-certificate http://updates.jenkins-ci.org/latest/myplug.hpi') }
    it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

  describe 'with version' do
    let(:params) { { :version => '1.2.3' } }

    it { should contain_exec('download-myplug').with_command('wget --no-check-certificate http://updates.jenkins-ci.org/download/plugins/myplug/1.2.3/myplug.hpi') }
    it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
  end

end
