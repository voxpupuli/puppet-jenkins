# Class: jenkins::cli
#
# Allow Jenkins commands to be issued from the command line
#
class jenkins::cli {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $jar = "${jenkins::libdir}/jenkins-cli.jar"
  $extract_jar = "jar -xf ${jenkins::libdir}/jenkins.war WEB-INF/jenkins-cli.jar"
  $move_jar = "mv WEB-INF/jenkins-cli.jar ${jar}"
  $remove_dir = 'rm -rf WEB-INF'

  exec { 'jenkins-cli' :
    command => "${extract_jar} && ${move_jar} && ${remove_dir}",
    path    => ['/bin', '/usr/bin'],
    cwd     => '/tmp',
    creates => $jar,
    require => Service['jenkins'],
  }

  file { $jar:
    ensure  => file,
    require => Exec['jenkins-cli'],
  }

  $port = jenkins_port()

  # The jenkins cli command with required parameter(s)
  $cmd = "java -jar ${jar} -s http://localhost:${port}"

  # Do a safe restart of Jenkins (only when notified)
  exec { 'safe-restart-jenkins':
    command     => "${cmd} safe-restart && /bin/sleep 10",
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
    require     => File[$jar],
  }
}
