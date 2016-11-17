# Define: jenkins::view::absent
#
#   Removes a view
#
#   This define should be considered public.
#
# Parameters:
#
#   view_name = $title
#     the name of the jenkins view
#
# Example:
#
# 1. jenkins::view::absent { 'view_name': }
#
define jenkins::view::absent (
  $view_name = $title
) {
  validate_string($view_name)

  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins views requires \$jenkins::service_ensure to be set to \'running\'')
  }

  # Bring variables from Class['::jenkins'] into local scope.
  $cli_tries     = $::jenkins::cli_tries
  $cli_try_sleep = $::jenkins::cli_try_sleep

  Exec {
    logoutput   => false,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
  }

  exec { "jenkins delete-view ${view_name}":
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "${jenkins::cli::cmd} delete-view \"${view_name}\"",
    logoutput => false,
    onlyif    => "${jenkins::cli::cmd} get-view \"${view_name}\"",
    require   => Exec['jenkins-cli']
  }
}
