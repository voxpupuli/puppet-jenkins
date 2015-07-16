node default {

  # requires stschulte/rpmkey

  package {'java-1.7.0-openjdk.x86_64':
    ensure => 'present',
  }
  ->
  # RHEL5 Workaround for RPM key
  # See https://groups.google.com/forum/?fromgroups#!topic/puppet-users/Yxiekm0j1J4
  rpmkey { 'D50582E6':
    ensure => present,
    source => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
  }
  ->
  class {'jenkins':
    install_java => false,
    cli          => true,
  }

  jenkins::plugin {
    'ansicolor' :
      version => '0.3.1';
  }

  jenkins::job {
    'build' :
      config => '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties></properties>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders/>
  <publishers/>
  <buildWrappers/>
</project>';
  }
}
