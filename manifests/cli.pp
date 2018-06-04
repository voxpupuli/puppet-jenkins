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
  if $::jenkins::manage_service {
    Class['jenkins::service']
      -> Class['jenkins::cli']
        -> Anchor['jenkins::end']
  }

  $jar = "${jenkins::libdir}/jenkins-cli.jar"
  $extract_jar = "jar -xf ${jenkins::libdir}/jenkins.war WEB-INF/jenkins-cli.jar"
  $move_jar = "mv WEB-INF/jenkins-cli.jar ${jar}"
  $remove_dir = 'rm -rf WEB-INF'

  # make sure we always call Exec[jenlins-cli] in case
  # the binary does not exist
  exec { 'check-jenkins-cli':
    command => '/bin/true',
    creates => $jar,
  }
  ~> exec { 'jenkins-cli' :
    command     => "${extract_jar} && ${move_jar} && ${remove_dir}",
    path        => ['/bin', '/usr/bin'],
    cwd         => '/tmp',
    refreshonly => true,
    require     => Class['::jenkins::service'],
  }
  # Extract latest CLI in case package is updated / downgraded
  Package[$::jenkins::package_name] ~> Exec['jenkins-cli']

  file { $jar:
    ensure  => file,
    mode    => '0644',
    require => Exec['jenkins-cli'],
  }

  $port = jenkins_port()
  $prefix = jenkins_prefix()

  # The jenkins cli command with required parameter(s)
  $cmd = join(
    delete_undef_values([
      'java',
      "-jar ${::jenkins::cli::jar}",
      "-s http://localhost:${port}${prefix}",
      $::jenkins::_cli_auth_arg,
    ]),
    ' '
  )

  # Do a safe restart of Jenkins (only when notified)
  exec { 'safe-restart-jenkins':
    command     => "${cmd} safe-restart && /bin/sleep 10",
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
    require     => File[$jar],
  }

  # jenkins::cli::reload should be included only after $::jenkins::cli::cmd is
  # defined
  include ::jenkins::cli::reload
}
