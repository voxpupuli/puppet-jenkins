require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

TEST_CONFIG1 = <<'EOS'
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>test job</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>/usr/bin/true</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOS

TEST_CONFIG2 = <<'EOS'
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>test job</description>
  <keepDependencies>true</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>true</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>true</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>/usr/bin/true</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOS

describe Puppet::Type.type(:jenkins_job) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end

    describe 'show_diff' do
      it_behaves_like 'boolean property', :show_diff, true
    end
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable'
    end

    describe 'enable' do
      it_behaves_like 'boolean property', :enable, true
    end

    describe 'config' do
      let(:config) { described_class.new(:resource => resource) }

      it { expect(described_class.attrtype('config')).to eq :config }

      [true, false].product([true, false]).each do |cfg, param|
        describe "and Puppet[:show_diff] is #{cfg} and show_diff => #{param}" do
          before do
            Puppet[:show_diff] = cfg
            resource.stubs(:show_diff?).returns param
            resource[:loglevel] = "debug"
          end

          if cfg and param
            it "should display a diff" do
              config.expects(:diff).returns("my diff").once
              config.expects(:debug).with("\nmy diff").once
              expect(content).not_to be_safe_insync("other content")
            end
          else
            it "should not display a diff" do
              config.expects(:diff).never
              expect(content).not_to_be_safe_insync("other content")
            end
          end
        end
      end
    end

  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'

    describe 'folders' do
      it "should autorequire parent folder resource" do
        folder = described_class.new(
          :name => 'foo',
        )

        job = described_class.new(
          :name => 'foo/bar',
        )

        folder[:ensure] = :present
        job[:ensure] = :present

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource folder
        catalog.add_resource job
        req = job.autorequire

        expect(req.size).to eq 1
        expect(req[0].source).to eq folder
        expect(req[0].target).to eq job
      end

      it "should autorequire multiple nested parent folder resources" do
        folder1 = described_class.new(
          :name => 'foo',
        )

        folder2 = described_class.new(
          :name => 'foo/bar',
        )

        job = described_class.new(
          :name => 'foo/bar/baz',
        )

        folder1[:ensure] = :present
        folder2[:ensure] = :present
        job[:ensure] = :present

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource folder1
        catalog.add_resource folder2
        catalog.add_resource job
        req = job.autorequire

        expect(req.size).to eq 2
        expect(req[0].source).to eq folder1
        expect(req[0].target).to eq job
        expect(req[1].source).to eq folder2
        expect(req[1].target).to eq job
      end
    end # folders
  end # autorequire
end
