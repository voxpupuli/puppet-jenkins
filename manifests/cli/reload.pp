# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::jenkins::cli_helper::ssh_keyfile {
    $auth_arg = "-i $::jenkins::cli_helper::ssh_keyfile" 
  } else {
    $auth_arg = undef
  }

  $run = join(
    delete_undef_values(
      flatten([
        $::jenkins::cli::cmd,
        $auth_arg,
        "reload-configuration"
      ])
    ),
    ' '
  )

  # Reload all Jenkins config from disk (only when notified)
  exec { 'reload-jenkins':
    command     => $run,
    tries       => $::jenkins::cli_tries,
    try_sleep   => $::jenkins::cli_try_sleep,
    refreshonly => true
  }
}
