require 'spec_helper'
require 'puppet/jenkins/plugins'

describe Puppet::Jenkins::Plugins do
  describe '.exists?' do
    subject(:exists) { described_class.exists? }

    context 'if jenkins does not exist' do
      before :each do
        Puppet::Jenkins.stub(:home_dir).and_return(nil)
      end

      it { should be false }
    end

    context 'if jenkins exists' do
      let(:home) { '/var/lib/jenkins' }
      let(:dir_exists) { false }

      before :each do
        Puppet::Jenkins.stub(:home_dir).and_return(home)
        File.should_receive(:directory?).with(File.join(home, 'plugins')).and_return(dir_exists)
      end

      context 'and the directory exists' do
        let(:dir_exists) { true }
        it { should be true }
      end

      context 'and the directory does not exist' do
        it { should be false}
      end
    end
  end

  describe '.available' do
    subject(:available) { described_class.available }

    context 'when plugins do not exist' do
      before :each do
        described_class.should_receive(:exists?).and_return(false)
      end

      it { should be_empty }
      it { should be_instance_of Hash }
    end

    context 'when plugins exist' do
      it 'should generate a list of plugins' do
        pending 'This is too hard to unit test, feh.'
        fail
      end
    end
  end

  describe 'manifest_data' do
    subject(:data) { described_class.manifest_data(data_str) }

    context 'with a plugin version that is hyphenated' do
      let(:data_str) do
        '
Plugin-Version: 1.7.2-1
Jenkins-Version: 1.456
'
      end

      it 'should have the properly hyphenated plugin version' do
        expect(data[:plugin_version]).to eql('1.7.2-1')
      end
    end

    context 'with "standard" looking manifest data' do
      let(:data_str) do
        '
Manifest-Version: 1.0
Archiver-Version: Plexus Archiver
Created-By: Apache Maven
Built-By: jglick
Build-Jdk: 1.7.0_11
Extension-Name: ant
Implementation-Title: ant
Implementation-Version: 1.2
Group-Id: org.jenkins-ci.plugins
Short-Name: ant
Long-Name: Ant Plugin
Url: http://wiki.jenkins-ci.org/display/JENKINS/Ant+Plugin
Plugin-Version: 1.2
Hudson-Version: 1.456
Jenkins-Version: 1.456
Plugin-Developers:

'
      end

      it { should be_instance_of Hash }

      it 'should parse the right plugin version' do
        expect(data[:plugin_version]).to eql('1.2')
      end
    end

    context 'with a more complex manifest' do
      let(:data_str) do
        '
Manifest-Version: 1.0
Archiver-Version: Plexus Archiver
Created-By: Apache Maven
Built-By: nicolas
Build-Jdk: 1.7.0_45
Extension-Name: git
Specification-Title: Integrates Jenkins with GIT SCM
Implementation-Title: git
Implementation-Version: 2.0.1
Group-Id: org.jenkins-ci.plugins
Short-Name: git
Long-Name: Jenkins GIT plugin
Url: http://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
Plugin-Version: 2.0.1
Hudson-Version: 1.480
Jenkins-Version: 1.480
Plugin-Dependencies: promoted-builds:2.7;resolution:=optional,token-ma
 cro:1.5.1;resolution:=optional,ssh-credentials:1.5.1,scm-api:0.1,cred
 entials:1.9.3,multiple-scms:0.2;resolution:=optional,parameterized-tr
 igger:2.4;resolution:=optional,git-client:1.6.0
Plugin-Developers: Kohsuke Kawaguchi:kohsuke:,Nicolas De Loof:ndeloof:
 nicolas.deloof@gmail.com

'
      end

      it { should be_instance_of Hash }
      it 'should have the right number of keys' do
        expect(data.keys.size).to eql(18)
      end
    end
  end

  describe '.plugins_from_updatecenter' do
    subject(:plugins) { described_class.plugins_from_updatecenter(fixture) }

    let(:fixture) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/update-center.json') }

    context 'uses json' do
      it { should be_instance_of Hash }
      it { should have_key('AdaptivePlugin')}
      its (:size) { should eql 1 }
    end

    context 'uses okjson when json is not avaliable' do
      before :each do
        expect(::Kernel).to receive(:require).with('json').and_raise(LoadError)
        expect(::Kernel).to receive(:require).with('puppet/jenkins/okjson').and_call_original
      end

      it { should be_instance_of Hash }
      it { should have_key('AdaptivePlugin')}
      its (:size) { should eql 1 }
    end

  end

  let(:git_plugin) do
    {'buildDate'=>'Jan 08, 2014',
    'dependencies'=>
      [{'name'=>'promoted-builds', 'optional'=>true, 'version'=>'2.7'},
      {'name'=>'token-macro', 'optional'=>true, 'version'=>'1.5.1'},
      {'name'=>'ssh-credentials', 'optional'=>false, 'version'=>'1.5.1'},
      {'name'=>'scm-api', 'optional'=>false, 'version'=>'0.1'},
      {'name'=>'credentials', 'optional'=>false, 'version'=>'1.9.3'},
      {'name'=>'multiple-scms', 'optional'=>true, 'version'=>'0.2'},
      {'name'=>'parameterized-trigger', 'optional'=>true, 'version'=>'2.4'},
      {'name'=>'git-client', 'optional'=>false, 'version'=>'1.6.0'}],
    'developers'=>
      [{'developerId'=>'kohsuke', 'name'=>'Kohsuke Kawaguchi'},
      {'developerId'=>'ndeloof',
        'email'=>'nicolas.deloof@gmail.com',
        'name'=>'Nicolas De Loof'}],
    'excerpt'=>
      "This plugin allows use of <a href='http://git-scm.com/'>Git</a> as a build SCM. A recent Git runtime is required (1.7.9 minimum, 1.8.x recommended). Plugin is only tested on official <a href='http://git-scm.com/'>git client</a>. Use exotic installations at your own risks.",
    'gav'=>'org.jenkins-ci.plugins:git:2.0.1',
    'labels'=>['scm'],
    'name'=>'git',
    'previousTimestamp'=>'2013-10-22T22:00:16.00Z',
    'previousVersion'=>'2.0',
    'releaseTimestamp'=>'2014-01-08T21:46:20.00Z',
    'requiredCore'=>'1.480',
    'scm'=>'github.com',
    'sha1'=>'r5bK/IP8soP08D55Xpcx5yWHzdY=',
    'title'=>'Git Plugin',
    'url'=>'http://updates.jenkins-ci.org/download/plugins/git/2.0.1/git.hpi',
    'version'=>'2.0.1',
    'wiki'=>'https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin'}
  end
end
