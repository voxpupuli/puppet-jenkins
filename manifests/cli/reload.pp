# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $cmd = join(
    delete_undef_values([
      $::jenkins::cli::cmd,
      $::jenkins::cli_helper::auth_arg,
      'reload-configuration',
    ]),
    ' '
  )

  # Reload all Jenkins config from disk (only when notified)
  exec { 'reload-jenkins':
    command     => $cmd,
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
  }
}
