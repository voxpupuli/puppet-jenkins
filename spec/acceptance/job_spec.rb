require 'spec_helper_acceptance'

describe 'jenkins::job' do
  let(:test_build_job) do
    example = <<'EOS'
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>test job</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>/usr/bin/true</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOS
    # escape single quotes for puppet
    example.gsub("'", %q(\\\'))
  end

  context 'create' do
    it 'works with no errors' do
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
      }

      # the historical assumption is that this will work without cli => true
      # set on the jenkins class
      jenkins::job { 'test-build-job':
        config => \'#{test_build_job}\',
      }
      EOS

      # Run it twice and test for idempotency
      apply(pp, catch_failures: true)
      # XXX idempotency is broken with at least jenkins 1.613
      # apply(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'jenkins' }
      it { is_expected.to be_grouped_into 'jenkins' }
      it { is_expected.to be_mode 644 }
      it { is_expected.to contain '<description>test job</description>' }
      it { is_expected.to contain '<disabled>false</disabled>' }
      it { is_expected.to contain '<command>/usr/bin/true</command>' }
    end
  end

  context 'no replace' do
    it 'does not replace an existing job' do
      pp_create = <<-EOS
        class {'jenkins':
          cli_remoting_free => true,
        }
        jenkins::job {'test-noreplace-job':
          config => \'#{test_build_job.gsub('<description>test job</description>', '<description>do not overwrite me</description>')}\',
        }
      EOS

      pp_update = <<-EOS
        class {'jenkins':
          cli_remoting_free => true,
        }
        jenkins::job {'test-noreplace-job':
          config  => \'#{test_build_job}\',
          replace => false,
        }
      EOS

      apply(pp_create, catch_failures: true)
      apply(pp_update, catch_failures: true)
    end

    describe file('/var/lib/jenkins/jobs/test-noreplace-job/config.xml') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'jenkins' }
      it { is_expected.to be_grouped_into 'jenkins' }
      it { is_expected.to be_mode 644 }
      it { is_expected.to contain '<description>do not overwrite me</description>' }
    end
  end

  context 'disable' do
    pending('Parameter $enabled is now deprecated, no need to test')
    it 'works with no errors' do
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
      }

      jenkins::job { 'test-build-job':
        config  => \'#{test_build_job}\',
        enabled => false,
      }
      EOS

      # Run it twice and test for idempotency
      apply(pp, catch_failures: true)
      # XXX idempotency is broken with at least jenkins 1.613
      # apply(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'jenkins' }
      it { is_expected.to be_grouped_into 'jenkins' }
      it { is_expected.to be_mode 644 }
      it { is_expected.to contain '<description>test job</description>' }
      it { is_expected.to contain '<command>/usr/bin/true</command>' }
    end
  end # deprecated param enabled

  context 'delete' do
    it 'works with no errors' do
      # create a test job so it can be deleted; job creation is not what
      # we're intending to be testing here
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
      }

      jenkins::job { 'test-build-job':
        config => \'#{test_build_job}\',
      }
      EOS

      apply(pp)

      # test job deletion
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
      }

      jenkins::job { 'test-build-job':
        ensure => 'absent',
        config => \'#{test_build_job}\',
      }
      EOS

      # Run it twice and test for idempotency
      apply(pp, catch_failures: true)
      # XXX idempotency is broken with at least jenkins 1.613
      # apply(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      # XXX Serverspec::Type::File doesn't support exists?
      it { is_expected.not_to be_file }
    end
  end
end
