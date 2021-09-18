require 'spec_helper'
require 'json'

describe Puppet::Type.type(:jenkins_slaveagent_port).provider(:cli) do
  describe '::instances' do
    context 'without any params' do
      before do
        allow(described_class).to receive(:get_slaveagent_port).
          with(nil).and_return(42)
      end

      it 'returns the correct number of instances' do
        expect(described_class.instances.size).to eq 1
      end

      context 'first instance returned' do
        let(:provider) { described_class.instances[0] }

        it { expect(provider.name).to eq 42 }
      end
    end

    context 'when called with a catalog param' do
      it 'passes it on ::get_slaveagent_port' do
        catalog = Puppet::Resource::Catalog.new

        allow(described_class).to receive(:get_slaveagent_port).
          with(catalog).and_return(42)

        described_class.instances(catalog)

        expect(described_class).to have_received(:get_slaveagent_port).
          with(catalog)
      end
    end
  end # ::instanes

  describe '#flush' do
    it 'calls set_slaveagent_port' do
      provider = described_class.new
      provider.create

      allow(provider).to receive(:set_slaveagent_port)
      provider.flush
      expect(provider).to have_received(:set_slaveagent_port).with(no_args)
    end

    it 'fails' do
      provider = described_class.new
      provider.destroy

      expect { provider.flush }.
        to raise_error(Puppet::Error, %r{invalid :ensure value: absent})
    end
  end # #flush

  #
  # private methods
  #

  describe '::get_slaveagent_port' do
    it do
      allow(described_class).to receive(:clihelper).
        with(['get_slaveagent_port'], catalog: nil).and_return(42)

      n = described_class.send :get_slaveagent_port
      expect(n).to eq 42

      expect(described_class).to have_received(:clihelper).
        with(['get_slaveagent_port'], catalog: nil)
    end
  end # ::get_slaveagent_port

  describe '#set_jenkins_instance' do
    it do
      provider = described_class.new(name: 42)

      allow(described_class).to receive(:clihelper)

      provider.send :set_slaveagent_port

      expect(described_class).to have_received(:clihelper).with(['set_slaveagent_port', 42])
    end
  end # #set_jenkins_instance
end
