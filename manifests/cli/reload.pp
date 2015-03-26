# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Reload all Jenkins config from disk (only when notified)
  exec { 'reload-jenkins':
    command     => "${::jenkins::cli::cmd} reload-configuration",
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
  }
}
