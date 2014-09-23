require_relative '../spec_helper'

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
      it { pending "Jenkins probably isn't running";
          should be_listening }
    end

    describe file('/usr/share/jenkins/jenkins-cli.jar') do
      it { should be_file }
    end

    describe service('jenkins') do
      it { should be_running }
      it { should be_enabled }
    end
  end
end
