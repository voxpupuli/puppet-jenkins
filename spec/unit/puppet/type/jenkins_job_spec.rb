require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_job) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end

    describe 'show_diff' do
      it_behaves_like 'boolean parameter', :show_diff, true
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
      let(:resource) { described_class.new(:name => 'foo', :config => 'bar') }
      let(:property) { resource.property(:config) }

      it { expect(described_class.attrtype(:config)).to eq :property }

      [true, false].product([true, false]).each do |cfg, param|
        describe "and Puppet[:show_diff] is #{cfg} and show_diff => #{param}" do
          before do
            Puppet[:show_diff] = cfg
            resource[:show_diff] = param
            resource[:loglevel] = 'debug'
          end

          if cfg and param
            it 'should display a diff' do
              property.stub(:diff).and_return('foo')
              expect(property).to receive(:diff).once
              property.change_to_s('foo', 'bar')
            end
          else
            it 'should not display a diff' do
              property.stub(:diff)
              expect(property).not_to receive (:diff)
              property.change_to_s('foo', 'bar')
            end
          end
        end
      end

      describe 'change_to_s change string' do

        context 'created' do
          it { expect(property.change_to_s(:absent, nil)) .to eq 'created' }
        end
        context 'removed' do
          it { expect(property.change_to_s(nil, :absent)).to eq 'removed' }
        end
        context 'changed' do
          it do
            expect(property.change_to_s('foo', 'bar'))
              .to match(/content changed '{md5}\w+' to '{md5}\w+'/)
          end
        end
      end #change_to_s change string
    end #config
  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'

    describe 'folders' do
      it 'should autorequire parent folder resource' do
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

      it 'should autorequire multiple nested parent folder resources' do
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

      it 'should autobefore multiple nested parent folder resources',
          :unless => Puppet.version.to_f < 4.0 do
        folder1 = described_class.new(
          :name => 'foo',
        )

        folder2 = described_class.new(
          :name => 'foo/bar',
        )

        job = described_class.new(
          :name => 'foo/bar/baz',
        )

        folder1[:ensure] = :absent
        folder2[:ensure] = :absent
        job[:ensure] = :absent

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource folder1
        catalog.add_resource folder2
        catalog.add_resource job
        req = job.autobefore

        expect(req.size).to eq 2
        expect(req[0].source).to eq job
        expect(req[0].target).to eq folder1
        expect(req[1].source).to eq job
        expect(req[1].target).to eq folder2
      end
    end # folders
  end # autorequire
end
