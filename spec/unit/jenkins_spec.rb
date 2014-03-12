require 'spec_helper'
require 'puppet/jenkins'

describe Puppet::Jenkins do
  describe '.home_dir' do
    subject(:home_dir) { described_class.home_dir }

    context "when a jenkins user doesn't exist" do
      before :each do
        File.should_receive(:expand_path).and_raise(ArgumentError)
      end

      it { should be_nil }
    end

    context 'when a jenkins user does exist' do
      let(:home) { '/rspec/jenkins' }

      before :each do
        File.should_receive(:expand_path).and_return(home)
      end

      it { should eql home }  
    end
  end
end
