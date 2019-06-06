# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {
  assert_private()

  $jar_file = $jenkins::cli::jar

  # Reload all Jenkins config from disk (only when notified)
  exec { 'reload-jenkins':
    command     => "${::jenkins::cli::cmd} reload-configuration",
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
    require     => File[$jar_file],
  }
}
