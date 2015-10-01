require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_providers'

describe Puppet::Type.type(:jenkins_job).provider(:cli) do
  let(:list_jobs_output) { "foo\nbar\n" }
  let(:foo_xml) do
    <<-EOS
<?xml version="1.0" encoding="UTF-8"?><project>
  <actions/>
  <description/>
  <keepDependencies>false</keepDependencies>
  <properties>
    <com.sonyericsson.rebuild.RebuildSettings plugin="rebuild@1.25">
      <autoRebuild>false</autoRebuild>
      <rebuildDisabled>false</rebuildDisabled>
    </com.sonyericsson.rebuild.RebuildSettings>
  </properties>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>
    EOS
  end
  let(:bar_xml) do
    foo_xml.sub('<disabled>false</disabled>', '<disabled>true</disabled>')
  end

  include_examples 'confines to cli dependencies'

  describe "::instances" do
    context "without any params" do
      before do
        expect(described_class).to receive(:list_jobs).
          with(nil) { ['foo', 'bar']}

        expect(described_class).to receive(:get_job).
          with('foo', nil) { foo_xml }

        expect(described_class).to receive(:job_enabled).
          with('foo', nil) { true }

        expect(described_class).to receive(:get_job).
          with('bar', nil) { bar_xml }

        expect(described_class).to receive(:job_enabled).
          with('bar', nil) { false }
      end

      it "should return the correct number of instances" do
        expect(described_class.instances.size).to eq 2
      end

      context "first instance returned" do
        let(:provider) do
          described_class.instances[0]
        end

        it { expect(provider.name).to eq 'foo' }
        it { expect(provider.config).to eq foo_xml }
        it { expect(provider.enable).to eq true }
      end

      context "second instance returned" do
        let(:provider) do
          described_class.instances[1]
        end

        it { expect(provider.name).to eq 'bar' }
        it { expect(provider.config).to eq bar_xml }
        it { expect(provider.enable).to eq false }
      end
    end

    context "when called with a catalog param" do
      it "should pass it on ::list_jobs, ::get_job, & ::job_enabled" do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:list_jobs).
          with(kind_of(Puppet::Resource::Catalog)) { ['foo'] }

        expect(described_class).to receive(:get_job).
          with('foo', kind_of(Puppet::Resource::Catalog))

        expect(described_class).to receive(:job_enabled).
          with('foo', kind_of(Puppet::Resource::Catalog))

        described_class.instances(catalog)
      end
    end
  end # ::instanes

  describe '#create' do
    it 'should do nothing' do
      provider = described_class.new
      expect(provider.ensure).to eq :absent
      provider.create
      expect(provider.ensure).to eq :absent
    end
  end # #create

  describe '#flush' do
    it 'should call create_job' do
      provider = described_class.new
      provider.ensure = :present

      expect(provider).to receive(:exists?) { false }
      expect(provider).to receive(:create_job)
      provider.flush
    end

    it 'should call update_job' do
      provider = described_class.new
      provider.ensure = :present

      expect(provider).to receive(:exists?) { true }
      expect(provider).to receive(:update_job)
      provider.flush
    end

    it 'should call delete_job' do
      provider = described_class.new
      provider.destroy

      expect(provider).to receive(:delete_job)
      provider.flush
    end
  end # #flush

  #
  # private methods
  #

  describe '::list_jobs' do
    it do
      expect(described_class).to receive(:cli).with(
        ['list-jobs'],
        {:catalog => nil}
      ) { list_jobs_output }

      ret = described_class.send :list_jobs
      expect(ret).to eq ['foo', 'bar']
    end
  end # ::list_jobs

  describe '::get_job' do
    it do
      expect(described_class).to receive(:cli).with(
        ['get-job', 'foo'],
        {:catalog => nil}
      ) { foo_xml }

      ret = described_class.send :get_job, 'foo'
      expect(ret).to eq foo_xml
    end
  end # ::get_job

  describe '::job_enabled' do
    it do
      expect(described_class).to receive(:clihelper).with(
        ['job_enabled', 'foo'],
        {:catalog => nil}
      ) { 'true' }

      ret = described_class.send :job_enabled, 'foo'
      expect(ret).to eq true
    end
  end # ::job_enabled

  describe '#create_job' do
    it do
      provider = described_class.new(
        :name   => 'foo',
        :config => foo_xml,
      )

      expect(described_class).to receive(:cli).with(
        ['create-job', 'foo'],
        {:stdin => foo_xml}
      )

      provider.send :create_job
    end
  end # #create_job

  describe '#update_job' do
    it do
      provider = described_class.new(
        :name   => 'foo',
        :config => foo_xml,
      )

      expect(described_class).to receive(:cli).with(
        ['update-job', 'foo'],
        {:stdin => foo_xml}
      )

      provider.send :update_job
    end
  end # #update_job

  describe '#delete_job' do
    it do
      provider = described_class.new(
        :name   => 'foo',
        :config => foo_xml,
      )

      expect(described_class).to receive(:cli).with(
        ['delete-job', 'foo']
      )

      provider.send :delete_job
    end
  end # #delete_job
end
