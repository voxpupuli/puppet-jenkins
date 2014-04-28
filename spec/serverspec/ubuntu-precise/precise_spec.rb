require 'spec_helper'

describe 'Ubuntu 12.04 (Precise)', :type => :serverspec do
  describe 'non-Jenkins properties' do
    describe port(22) do
      it { should be_listening }
    end

    describe port(80) do
      it { should_not be_listening }
    end
  end

  describe 'Jenkins-specific configuration' do
    describe port(8080) do
      it { should be_listening }
    end

    describe service('jenkins') do
      it { should be_running }
      it { should be_enabled }
    end
  end
end
