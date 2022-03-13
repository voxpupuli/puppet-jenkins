# frozen_string_literal: true

require 'spec_helper'
require 'unit/puppet/x/spec_jenkins_providers'

require 'json'

describe Puppet::Type.type(:jenkins_job).provider(:cli) do
  let(:list_jobs_output) { "foo\nbar\n" }
  let(:foo_xml) do
    <<~EOS
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
  let(:job_list_json_output) do
    <<-'EOS'
    [
        {
            "name": "enabled-job",
            "config": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "enabled": true
        },
        {
            "name": "disabled-job",
            "config": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "enabled": false
        }
    ]
    EOS
  end
  let(:job_list_json_info) { JSON.parse(job_list_json_output) }

  include_examples 'confines to cli dependencies'

  describe '::instances' do
    context 'without any params' do
      before do
        allow(described_class).to receive(:job_list_json).
          with(nil).and_return(job_list_json_info)
      end

      it 'returns the correct number of instances' do
        expect(described_class.instances.size).to eq 2
      end

      context 'first instance returned' do # rubocop:todo RSpec/MultipleMemoizedHelpers
        let(:provider) do
          described_class.instances[0]
        end

        it { expect(provider.name).to eq 'enabled-job' }
        it { expect(provider.enable).to eq true }
      end

      context 'second instance returned' do # rubocop:todo RSpec/MultipleMemoizedHelpers
        let(:provider) do
          described_class.instances[1]
        end

        it { expect(provider.name).to eq 'disabled-job' }
        it { expect(provider.enable).to eq false }
      end
    end

    context 'when called with a catalog param' do
      it 'passes it on ::get_job_list' do
        catalog = Puppet::Resource::Catalog.new

        allow(described_class).to receive(:job_list_json).
          with(kind_of(Puppet::Resource::Catalog)).and_return(job_list_json_info)

        described_class.instances(catalog)

        expect(described_class).to have_received(:job_list_json).
          with(kind_of(Puppet::Resource::Catalog))
      end
    end
  end

  describe '#create' do
    it 'does nothing' do
      provider = described_class.new
      expect(provider.ensure).to eq :absent
      provider.create
      expect(provider.ensure).to eq :absent
    end
  end

  describe '#flush' do
    it 'calls create_job' do
      provider = described_class.new
      provider.ensure = :present

      allow(provider).to receive(:exists?).and_return(false)
      allow(provider).to receive(:create_job)
      provider.flush
      expect(provider).to have_received(:create_job)
    end

    it 'calls update_job when replacing' do
      provider = described_class.new
      provider.ensure = :present

      allow(provider).to receive(:exists?).and_return(true)
      allow(provider).to receive(:update_job)
      provider.flush
      expect(provider).to have_received(:update_job)
    end

    it 'doesn\'t calls update_job when not replacing' do
      provider = described_class.new
      provider.ensure = :present
      provider.replace = false

      allow(provider).to receive(:exists?).and_return(true)
      allow(provider).to receive(:update_job)
      provider.flush
      expect(provider).not_to have_received(:update_job)
    end

    it 'calls delete_job' do
      provider = described_class.new
      provider.destroy

      allow(provider).to receive(:delete_job)
      provider.flush
      expect(provider).to have_received(:delete_job)
    end
  end

  #
  # private methods
  #

  describe '::list_jobs' do
    it do
      allow(described_class).to receive(:cli).with(
        ['list-jobs'],
        catalog: nil
      ).and_return(list_jobs_output)

      ret = described_class.send :list_jobs
      expect(ret).to eq %w[foo bar]
      expect(described_class).to have_received(:cli).with(
        ['list-jobs'],
        catalog: nil
      )
    end
  end

  describe '::get_job' do
    it do
      allow(described_class).to receive(:cli).with(
        %w[get-job foo],
        catalog: nil
      ).and_return(foo_xml)

      ret = described_class.send :get_job, 'foo'
      expect(ret).to eq foo_xml
      expect(described_class).to have_received(:cli).with(
        %w[get-job foo],
        catalog: nil
      )
    end
  end

  describe '::job_enabled' do
    it do
      allow(described_class).to receive(:clihelper).with(
        %w[job_enabled foo],
        catalog: nil
      ).and_return('true')

      ret = described_class.send :job_enabled, 'foo'
      expect(ret).to eq true
      expect(described_class).to have_received(:clihelper).with(
        %w[job_enabled foo],
        catalog: nil
      )
    end
  end

  describe '#create_job' do
    it do
      provider = described_class.new(
        name: 'foo',
        config: foo_xml
      )

      allow(described_class).to receive(:cli)

      provider.send :create_job
      expect(described_class).to have_received(:cli).with(
        %w[create-job foo],
        stdin: foo_xml
      )
    end
  end

  describe '#update_job' do
    it do
      provider = described_class.new(
        name: 'foo',
        config: foo_xml
      )

      allow(described_class).to receive(:cli)

      provider.send :update_job

      expect(described_class).to have_received(:cli).with(
        %w[update-job foo],
        stdin: foo_xml
      )
    end
  end

  describe '#delete_job' do
    it do
      provider = described_class.new(
        name: 'foo',
        config: foo_xml
      )

      allow(described_class).to receive(:cli)

      provider.send :delete_job

      expect(described_class).to have_received(:cli).with(
        %w[delete-job foo]
      )
    end
  end
end
