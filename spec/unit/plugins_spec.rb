require 'spec_helper'
require 'lib/facter/jenkins'

describe Jenkins::Facts do
  describe '.jenkins_home' do
    subject(:home) { described_class.jenkins_home }

    it 'should resolve to ~jenkins' do
      expect(Facter::Util::Resolution).to \
            receive(:exec).with('echo ~jenkins').and_return('/var/lib/jenkins')
      expect(home).not_to be_nil
    end
  end
end

describe Jenkins::Facts::Plugins do
  describe '.exists?' do
    subject(:exists) { described_class.exists? }

    context 'if jenkins does not exist' do
      before :each do
        Jenkins::Facts.stub(:jenkins_home).and_return(nil)
      end

      it { should be false }
    end

    context 'if jenkins exists' do
      let(:home) { '/var/lib/jenkins' }
      let(:dir_exists) { false }

      before :each do
        Jenkins::Facts.stub(:jenkins_home).and_return(home)
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

  describe '.plugins' do
    subject(:plugins) { described_class.plugins }

    context 'when plugins do not exist' do
      before :each do
        Jenkins::Facts::Plugins.should_receive(:exists?).and_return(false)
      end

      it { should eql('') }
    end

    context 'when plugins exist' do
      it 'should generate a list of plugins' do
        pending 'This is too hard to unit test, feh.'
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
end

describe 'jenkins_plugins fact', :type => :fact do
  let(:fact) { Facter.fact(:jenkins_plugins) }
  subject(:plugins) { fact.value }

  before :each do
    Facter.fact(:kernel).stubs(:value).returns(kernel)
    Jenkins::Facts.add_facts
  end

  context 'on Linux' do
    let(:kernel) { 'Linux' }

    context 'with no plugins' do
      it { should be_nil }
    end

    context 'with plugins' do
      let(:plugins_str) { 'ant 1.2, git 2.0.1' }
      before :each do
        Jenkins::Facts::Plugins.should_receive(:plugins).and_return(plugins_str)
      end

      it { should eql(plugins_str) }
    end
  end

  context 'on FreeBSD' do
    let(:kernel) { 'FreeBSD' }

    it { should be_nil }
  end
end
