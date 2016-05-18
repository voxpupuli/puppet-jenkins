# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Reload all Jenkins config from disk (only when notified)
  #if ($::osfamily == 'Windows') {
    exec { 'reload-jenkins':
      command     => "${::jenkins::cli::cmd} reload-configuration",
      tries       => 10,
      try_sleep   => 2,
      refreshonly => true,
      provider => $jenkins::provider,
      path     => $jenkins::path,
    }
  #}
  #else {
   # exec { 'reload-jenkins':
   #   command     => "${::jenkins::cli::cmd} reload-configuration",
   #   path        => ['/bin', '/usr/bin'],
   #   tries       => 10,
   #   try_sleep   => 2,
   #   refreshonly => true,
   # }
 # }
}
