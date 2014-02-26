require 'spec_helper'

describe 'jenkins::firewall' do

  describe 'with firewall' do
    let(:pre_condition) { "define firewall($action, $state, $dport, $proto) {}" }
#    pending "not sure how to implement this"
    it { should contain_firewall('500 allow Jenkins inbound traffic') }
  end

end
