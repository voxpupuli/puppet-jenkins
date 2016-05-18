require 'rubygems'
require 'rspec'


module Jenkins
  module RSpecHelpers
    def clear_facts
    end

    shared_context 'custom fact example', :type => :fact do
      # Need to make sure we clear out our facts at the start to make sure that
      # we don't pick up some facts left over from rspec-puppet
      #
      # Also clear at the end to be a good citizen
      around :each do
        Facter.clear
        Facter.clear_messages
      end
    end

    shared_context 'module pre-conditions', :type => :module do
      let(:pre_condition) { [] }

      before :each do
        if pre_condition.instance_of? Array
          pre_condition << 'class stdlib {}'
        else
          pre_condition = "class stdlib {} \n #{pre_condition}"
        end
      end
    end
  end
end
