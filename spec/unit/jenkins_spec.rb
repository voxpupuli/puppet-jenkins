require 'spec_helper'
require 'puppet/jenkins'

describe Puppet::Jenkins do
  describe '.home_dir' do
    subject(:home_dir) { described_class.home_dir }

    context "when a jenkins user doesn't exist" do
      before do
        File.should_receive(:expand_path).and_raise(ArgumentError)
      end

      it { is_expected.to be_nil }
    end

    context 'when a jenkins user does exist' do
      let(:home) { '/rspec/jenkins' }

      before do
        File.should_receive(:expand_path).and_return(home)
      end

      it { is_expected.to eql home }
    end
  end
end
