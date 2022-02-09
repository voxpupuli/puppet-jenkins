# @summary Command Jenkins to reload config.xml via the CLI.
# @api private
class jenkins::cli::reload {
  assert_private()

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $cli_tries = $::jenkins::cli_tries
  $cli_try_sleep = $::jenkins::cli_try_sleep
  $jar_file = $jenkins::cli::jar

  # Reload all Jenkins config from disk (only when notified)
  exec { 'reload-jenkins':
    command     => "${jenkins::cli::cmd} reload-configuration",
    path        => ['/bin', '/usr/bin'],
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
    refreshonly => true,
    require     => File[$jar_file],
  }
}
