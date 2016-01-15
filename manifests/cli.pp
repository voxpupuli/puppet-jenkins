# Class: jenkins::cli
#
# Allow Jenkins commands to be issued from the command line
#
class jenkins::cli {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include ::jenkins

  # XXX Classes/defines which include the jenkins::cli class assume that they
  # can use the cli even if $::jenkins::cli == false.  This breaks the top
  # level anchor pattern.  The cli param should either be deprecated and
  # essentially hardwired to true or attempting to use cli functionality
  # without this param set should fail; either option is a backwards
  # incompatible change.
  #
  # As an attempt to preserve backwards compatibility, there are includes and
  # resource relationships being scattered throughout this module.
  Class['jenkins::service'] ->
    Class['jenkins::cli'] ->
      Anchor['jenkins::end']
  $jar = "${jenkins::libdir}/jenkins-cli.jar"
  case $::osfamily {
    'Windows': {
      $extract_jar = "start-sleep 30; \$j=[Environment]::GetEnvironmentVariable('JAVA_HOME','machine'); & \"\$j/bin/jar\" -xf \"${jenkins::libdir}/jenkins.war\" WEB-INF/jenkins-cli.jar"
      $move_jar    = "move-item WEB-INF/jenkins-cli.jar '${jar}'"
      $remove_dir  = 'remove-item -recurse -force WEB-INF'
      $and_var	   = ';'
      $path	   = ''
      $cwd	   = $jenkins::libdir
      $sleep_cmd  = 'start-sleep -seconds 10'
    }
    default: {
      $extract_jar = "jar -xf ${jenkins::libdir}/jenkins.war WEB-INF/jenkins-cli.jar"
      $move_jar    = "mv WEB-INF/jenkins-cli.jar ${jar}"
      $remove_dir  = 'rm -rf WEB-INF'
      $and_var     = '&&'
      $path	   = "['/bin', '/usr/bin']"
      $cwd	   = '/tmp'
      $sleep_cmd  = '/bin/sleep 10'
    }
  }
  
  if ($::operatingsystem == 'windows')  {
    #In windows, there is a pause here because jenkins takes a while to start up in windows
    exec { 'jenkins-cli' :
      command  => "${extract_jar} ${and_var} ${move_jar} ${and_var} ${remove_dir}",
      path     => $path,
      cwd      => $cwd,
      creates  => "${jar}",
      require  => Service['jenkins'],
      provider => 'powershell',
    }
  } else {
    exec { 'jenkins-cli' :
      command => "${extract_jar} ${and_var} ${move_jar} ${and_var} ${remove_dir}",
      path    => $path,
      cwd     => $cwd,
      creates => $jar,
      require => Service['jenkins'],
    }
  }
  
  file { "${jar}":
    ensure  => file,
    require => Exec['jenkins-cli'],
  }

  $port = jenkins_port()
  $prefix = jenkins_prefix()

  # Provide the -i flag if specified by the user.
  if $::jenkins::cli_ssh_keyfile {
    $auth_arg = "-i ${::jenkins::cli_ssh_keyfile}"
  } else {
    $auth_arg = undef
  }

  # The jenkins cli command with required parameter(s)
  case $::osfamily {
    'Windows': {
      $cmd = join(
        delete_undef_values([
          "\"\${env:JAVA_HOME}/bin/java\"",
          "-jar \"${::jenkins::cli::jar}\"",
          "-s http://localhost:${port}${prefix}",
          $auth_arg,
        ]),
        ' '
       )
    }
	default: {
	  $cmd = join(
        delete_undef_values([
          'java',
          "-jar \"${::jenkins::cli::jar}\"",
          "-s http://localhost:${port}${prefix}",
          $auth_arg,
        ]),
        ' '
       )
	}
  }
  # Do a safe restart of Jenkins (only when notified)
  exec { 'safe-restart-jenkins':
    command     => "${cmd} safe-restart ${and_var} ${sleep_cmd}",
    path        => $path,
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
    require     => File[$jar],
  }

  # jenkins::cli::reload should be included only after $::jenkins::cli::cmd is
  # defined
  include ::jenkins::cli::reload
}
