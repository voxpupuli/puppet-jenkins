# Class: jenkins::slave
#
#
#  ensure is not immplemented yet, since i'm
#  assuming you want to actually run the slave
#  by declaring it..
#
class jenkins::slave (
  $masterurl = undef,
  $ui_user = undef,
  $ui_pass = undef,
  $version = '1.9',
  $executors = 2,
  $manage_slave_user = 1,
  $slave_user = 'jenkins-slave',
  $slave_uid = undef,
  $slave_home = '/home/jenkins-slave',
  $labels = undef,
  $java_version = '1.6.0'
) {

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/"

  case $::osfamily {
    'RedHat': {
      $java_package = "java-${$java_version}-openjdk"
      $template_name = 'jenkins-slave.RedHat.erb' 
    }
    'Linux': {
      $java_package = "java-${$java_version}-openjdk"
      $template_name = 'jenkins-slave.RedHat.erb' 
    }
    'Debian': {
      $java_package='openjdk-6-jre'
      $template_name = 'jenkins-slave.Debian.erb' 
    }
    'windows': {
      # nothing specific yet...
    }
    default: {
      fail( "Unsupported OS family: ${::osfamily}" )
    }
  }


  #
  # Add a jenkins slave if necessary.
  #
  case $::osfamily {
    'windows': {
      #    Install the Jenkins swarm client as a Windows Service on a
      #    Windows Server system.
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

      $windows_slave_home = "${systemdrive}\\ProgramData\\jenkins_slave"

      windows_common::configuration::feature { 'NET-Framework-Features':
        ensure => present,
      }

      class { 'windows_java': }
	  #
	  # Bug - need to modify windows_java to export the java_path variable
	  #
      #$java_path = ${::windows_java::params::java_path}
	  $java_path = "${systemdrive}\\Program Files (x86)\\Java\\jdk1.7.0_21\\bin"
  
      file { $windows_slave_home:
        ensure => directory,
      }

      windows_common::remote_file { 'swarm_client':
        source      => "${client_url}/${client_jar}",
        destination => "${windows_slave_home}/${client_jar}",
        require     => File[$windows_slave_home],
      }

	  file { "${windows_slave_home}\\jenkins-slave.exe":
	    ensure  => file,
		source  => "puppet:///modules/jenkins/jenkins-slave.exe",
		require  => File[ "${windows_slave_home}" ],
	  }
	  
	  file { "${windows_slave_home}\\jenkins-slave.xml":
	    ensure  => file,
		content => template("jenkins/jenkins-slave.xml.erb"),
		require  => File[ "${windows_slave_home}" ],
	  }
	  
	  file { "${windows_slave_home}\\jenkins-slave.exe.config":
	    ensure  => file,
		content => template("jenkins/jenkins-slave.exe.config.erb"),
		require  => File["${windows_slave_home}"],
	  }
	  
	  exec {  'sc_create_service':
	    command => "${systemdrive}\\windows\\system32\\sc.exe create JenkinsSlave start=auto binPath=${windows_slave_home}\\jenkins-slave.exe displayName=\"Jenkins Slave\"",
        require => File[ "${windows_slave_home}\\jenkins-slave.exe", "${windows_slave_home}\\jenkins-slave.xml" ],
	  }
	  
    }
    default: {
      #
      # For now, the default case handles all flavors of Linux
      #
      if $manage_slave_user == 1 and $slave_uid {
        user { 'jenkins-slave_user':
          ensure     => present,
          name       => $slave_user,
          comment    => 'Jenkins Slave user',
          home       => $slave_home,
          managehome => true,
          uid        => $slave_uid
        }
      }

      if ($manage_slave_user == 1) and (! $slave_uid) {
        user { 'jenkins-slave_user':
          ensure     => present,
          name       => $slave_user,
          comment    => 'Jenkins Slave user',
          home       => $slave_home,
          managehome => true,
        }
      }

      package { $java_package:
        ensure => installed;
      }

      exec { 'get_swarm_client':
        command      => "wget -O ${slave_home}/${client_jar} ${client_url}/${client_jar}",
        path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        user         => $slave_user,
        #refreshonly => true,
        creates      => "${slave_home}/${client_jar}"
        ## needs to be fixed if you create another version..
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

      file { '/etc/init.d/jenkins-slave':
          ensure  => 'file',
          mode    => '0700',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/${template_name}"),
          notify  => Service['jenkins-slave']
      }

      service { 'jenkins-slave':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }

      Package[ $java_package ]
      -> Exec['get_swarm_client']
      -> Service['jenkins-slave']
    }
  }
}
