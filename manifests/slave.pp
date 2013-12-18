# == Class: jenkins::slave
#
# This module setups up a swarm client for a jenkins server.  It requires the swarm plugin on the Jenkins master.
#
# https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
#
# It allows users to add more workers to Jenkins without having to specifically add them on the Jenkins master.
#
# === Parameters
#
# [*masterurl*]
#   Specify the URL of the master server.  Not required, the plugin will do a UDP autodiscovery. If specified, the autodiscovery will be skipped.
#
# [*ui_user*] & [*ui_pass*]
#   User name & password for the Jenkins UI.  Not required, but may be ncessary for your config, depending on your security model.
#
# [*version*]
#   The version of the swarm client code. Must match the pluging version on the master.  Typically it's the latest available.
#
# [*executors*]
#   Number of executors for this slave.  (How many jenkins jobs can run simultaneously on this host.)
#
# [*manage_slave_user*]
#   Should the class add a user to run the slave code?  1 is currently true
#   TODO: should be updated to use boolean.
#
# [*slave_user*]
#   Defaults to 'jenkins-slave'. Change it if you'd like..
#
# [*slave_uid*]
#   Not required.  Puppet will let your system add the user, with the new UID if necessary.
#
# [*slave_home*]
#   Defaults to '/home/jenkins-slave'.  This is where the code will be installed, and the workspace will end up.
#
# [*labels*]
#   Not required.  Single string of whitespace-separated list of labels to be assigned for this slave.
#
# [*jave_version*]
#   Specified which version of java will be used.
#

# === Examples
#
#  class { 'jenkins::slave':
#    masterurl => 'http://jenkins-master1.example.com:8080',
#    ui_user => 'adminuser',
#    ui_pass => 'adminpass',
#  }
#
# === Authors
#
# Matthew Barr <mbarr@mbarr.net>
#
# === Copyright
#
# Copyright 2013 Matthew Barr , but can be used for anything by anyone..

class jenkins::slave (
  $masterurl         = undef,
  $ui_user           = undef,
  $ui_pass           = undef,
  $version           = $jenkins::params::swarm_version,
  $executors         = 2,
  $manage_slave_user = true,
  $slave_user        = 'jenkins-slave',
  $slave_uid         = undef,
  $slave_home        = $jenkins::params::slave_home,
  $labels            = undef,
  $install_java      = $jenkins::params::install_java,
  $enable            = true
) inherits jenkins::params {

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/"

  if $install_java {
    class {'java':
      distribution => 'jdk'
    }
  }

  #add jenkins slave user if necessary.

  if $manage_slave_user and $slave_uid {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
      uid        => $slave_uid
    }
  }

  if ($manage_slave_user) and (! $slave_uid) {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
    }
  }

  if $ui_user {
    $ui_user_flag = "-username ${ui_user}"
  }
  else {$ui_user_flag = ''}

  if $ui_pass {
    $ui_pass_flag = "-password ${ui_pass}"
  } else {
    $ui_pass_flag = ''
  }

  if $masterurl {
    $masterurl_flag = "-master ${masterurl}"
  } else {
    $masterurl_flag = ''
  }

  if $labels {
    $labels_flag = "-labels \"${labels}\""
  } else {
    $labels_flag = ''
  }

  #
  # Perform OS specific tasks
  #
  case $::osfamily {
    'windows': {
      #    Install the Jenkins swarm client as a Windows Service.
      #
      #    The Jenkins swarm client is a Java application.  To run
      #    a Java application as a Windows service, you need a
      #    service "wrapper".  Jenkins provides a Windows service
      #    wrapper which is named:
      #        jenkins-slave.exe
      #
      #    The jenkins-slave.exe service wrapper was written using
      #    the Microsoft .NET Framework 2.0.  Because of this, the
      #    Windows server where the jenkins-slave.exe will be installed
      #    as a service will need to have the .NET Framework 3.5
      #    installed (.NET 3.5 provides support for .NET 2.0).
      #
      #    Note: The following depends on the windows_common module.
      #

      windows_common::configuration::feature { 'NET-Framework-Features':
        ensure => present,
      }

      #
      # Bug - need to modify windows_java to export the java_path variable
      #
      #$java_path = ${::java::params::java_path}
      $java_path = "${systemdrive}\\Program Files\\Java\\jre7\\bin"
  
      file { $slave_home:
        ensure => directory,
      }

      windows_common::remote_file { 'swarm_client':
        source      => "${client_url}/${client_jar}",
        destination => "${slave_home}/${client_jar}",
        require     => File[$slave_home],
      }

      file { "${slave_home}\\jenkins-slave.exe":
        ensure  => file,
        mode    => 0777,
        source  => "puppet:///modules/jenkins/jenkins-slave.exe",
        require  => File[ "${slave_home}" ],
      }
	  
      file { "${slave_home}\\jenkins-slave.xml":
        ensure  => file,
        content => template("jenkins/jenkins-slave.xml.erb"),
        require  => File[ "${slave_home}" ],
      }
	  
      file { "${slave_home}\\jenkins-slave.exe.config":
        ensure  => file,
        content => template("jenkins/jenkins-slave.exe.config.erb"),
        require  => File["${slave_home}"],
      }
	  
      exec {  'sc_create_service':
        command => "${systemdrive}\\windows\\system32\\sc.exe create JenkinsSlave start=auto binPath=${slave_home}\\jenkins-slave.exe displayName=\"Jenkins Slave\"",
        require => File[ "${slave_home}\\jenkins-slave.exe", "${slave_home}\\jenkins-slave.xml" ],
      }
	  
      exec { 'sc_start_jenkinsslave':
        command => "${systemdrive}\\windows\\system32\\sc.exe start JenkinsSlave",
        require => Exec[ "sc_create_service" ],
      }
    }
    default: {
      exec { 'get_swarm_client':
        command      => "wget -O ${slave_home}/${client_jar} ${client_url}/${client_jar}",
        path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        user         => $slave_user,
        #refreshonly => true,
        creates      => "${slave_home}/${client_jar}"
        ## needs to be fixed if you create another version..
      }

      file { '/etc/init.d/jenkins-slave':
        ensure  => 'file',
        mode    => '0700',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/${service_file}"),
        notify  => Service['jenkins-slave']
      }

      service { 'jenkins-slave':
        ensure     => running,
        enable     => $enable,
        hasstatus  => true,
        hasrestart => true,
      }

      Exec['get_swarm_client']
      -> Service['jenkins-slave']

      if $install_java {
        Class['java'] ->
          Service['jenkins-slave']
      }
    }
  }
}
