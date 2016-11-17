# Define: jenkins::view::present
#
#   Creates or updates a view
#
#   This define should be considered public.
#
# Parameters:
#
#   config
#     the content of the jenkins view config file (required)
#
#   view_name = $title
#     the name of the jenkins view
#
# Example:
#
# 1. jenkins::view::present { 'view_name':
#      config => 'jenkins/view.xml.erb'
#    }
#
# 2. jenkins::view::present { 'view':
#      view_name => 'view_name'
#      config    => 'jenkins/view.xml.erb'
#    }
#
define jenkins::view::present (
  $config     = undef,
  $view_name  = $title,
) {
  validate_string($config)
  validate_string($view_name)

  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins views requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli     = $jenkins::cli::cmd
  $tmp_config_path = "/tmp/${title}-config.xml"
  $cat_config      = "cat \"${tmp_config_path}\""

  file { $tmp_config_path:
    content => template($config),
    require => Exec['jenkins-cli'],
  }

  # Bring variables from Class['::jenkins'] into local scope.
  $cli_tries     = $::jenkins::cli_tries
  $cli_try_sleep = $::jenkins::cli_try_sleep

  Exec {
    logoutput   => false,
    path        => "/bin:/usr/bin:/sbin:/usr/sbin:${jenkins::jdk_home}/bin",
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
  }

  $create_view = "${jenkins_cli} create-view \"${view_name}\""
  exec { "jenkins create-view ${title}":
    command => "${cat_config} | ${create_view}",
    unless  => "${jenkins_cli} get-view \"${view_name}\"",
    require => File[$tmp_config_path]
  }

  $update_view = "${jenkins_cli} update-view ${view_name}"
  exec { "jenkins update-view ${title}":
    command => "${cat_config} | ${update_view}",
    onlyif  => "${jenkins_cli} get-view \"${view_name}\"",
    require => File[$tmp_config_path],
    notify  => Exec['reload-jenkins']
  }
}
