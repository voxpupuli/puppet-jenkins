require 'spec_helper_acceptance'

describe 'jenkins::slave class' do
  include_context 'jenkins'

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::jenkins::slave
      EOS

      # Run it twice and test for idempotency
      apply(pp, :catch_failures => true)
      apply(pp, :catch_changes => true)
    end

    if fact('systemd') == 'true'
      describe file('/lib/systemd/system/jenkins-slave.service') do
        it { should be_file }
        it { should contain "ExecStart=#{$libdir}/jenkins-slave-run" }
      end
      describe file('/etc/init.d/jenkins-slave') do
        it { should_not exist }
      end
      describe service('jenkins-slave') do
        it { should be_running.under('systemd') }
      end
    else
      describe file('/lib/systemd/system/jenkins-slave.service') do
        it { should_not exist }
      end
      describe file('/etc/init.d/jenkins-slave') do
        it { should be_file }
        it { should be_mode 755 }
      end
    end

    describe file("#{$sysconfdir}/jenkins-slave") do
      it { should be_file }
      it { should be_mode 600 }
    end

    describe file('/home/jenkins-slave/swarm-client-2.2-jar-with-dependencies.jar') do
      it { should be_file }
      it { should be_mode 644 }
    end

    describe service('jenkins-slave') do
      it { should be_running }
      it { should be_enabled }
    end
  end # default parameters
end
