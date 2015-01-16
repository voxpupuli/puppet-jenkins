require 'spec_helper_acceptance'

describe 'jenkins class' do

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins':
        cli => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end

    describe port(8080) do
      it {
        pending "Jenkins probably isn't running"
        should be_listening
      }
      end
    end

    describe file('/usr/share/jenkins/jenkins-cli.jar') do
      it { should be_file }
    end

    describe service('jenkins') do
      it { should be_running }
      it { should be_enabled }
    end

end