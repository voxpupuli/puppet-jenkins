require 'spec_helper_acceptance'

describe 'jenkins::job' do
  let(:test_build_job) {
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
  }

  context 'create' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins': }

      # the historical assumption is that this will work without cli => true
      # set on the jenkins class
      jenkins::job { 'test-build-job':
        config => \'#{test_build_job}\',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # XXX idempotency is broken with at least jenkins 1.613
      #apply_manifest(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      it { should be_file }
      it { should be_owned_by 'jenkins' }
      it { should be_grouped_into 'jenkins' }
      it { should be_mode 644 }
      it { should contain '<description>test job</description>' }
      it { should contain '<disabled>false</disabled>' }
      it { should contain '<command>/usr/bin/true</command>' }
    end
  end

  context 'disable' do
    it 'should work with no errors' do
      pp = <<-EOS
      class {'jenkins': }

      jenkins::job { 'test-build-job':
        config  => \'#{test_build_job}\',
        enabled => false,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # XXX idempotency is broken with at least jenkins 1.613
      #apply_manifest(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      it { should be_file }
      it { should be_owned_by 'jenkins' }
      it { should be_grouped_into 'jenkins' }
      it { should be_mode 644 }
      it { should contain '<description>test job</description>' }
      it { should contain '<disabled>true</disabled>' }
      it { should contain '<command>/usr/bin/true</command>' }
    end
  end

  context 'delete' do
    it 'should work with no errors' do
      # create a test job so it can be deleted; job creation is not what
      # we're intending to be testing here
      pp = <<-EOS
      class {'jenkins': }

      jenkins::job { 'test-build-job':
        config => \'#{test_build_job}\',
      }
      EOS

      apply_manifest(pp)

      # test job deletion
      pp = <<-EOS
      class {'jenkins': }

      jenkins::job { 'test-build-job':
        ensure => 'absent',
        config => \'#{test_build_job}\',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # XXX idempotency is broken with at least jenkins 1.613
      #apply_manifest(pp, :catch_changes => true)
    end

    describe file('/var/lib/jenkins/jobs/test-build-job/config.xml') do
      # XXX Serverspec::Type::File doesn't support exists?
      it { should_not be_file }
    end
  end
end
