# Define: jenkins::job::present
#
#   Creates or updates a jenkins build job
#
#   This define should be considered private.
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (template based)
#
#   tmp_config_path
#     the jenkins job config file (file on disk)
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled
#     deprecated parameter (will have no effect if set)
#
define jenkins::job::present(
  $config = undef,
  $tmp_config_path = undef,
  $jobname  = $title,
  $enabled  = undef,
  $difftool = '/usr/bin/diff -b -q',
){
  validate_string($config)
  validate_string($jobname)
  validate_string($difftool)

  include jenkins::cli
  include jenkins::cli::reload

  if $tmp_config_path != undef and $config != undef {
    fail('You cannot set both \$tmp_config_path AND $config param, only one is required')
  }

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli        = $jenkins::cli::cmd
  if $tmp_config_path == undef {
    if $config == undef {
      fail('If you don\'t give a tmp_config_path you need to set the config param')
    }
    jenkins::job::create_tmp_file { $title:
      config => $config,
    }
    $tmp_config_path    = "/tmp/${jobname}-config.xml"
  }

  $job_dir            = "${::jenkins::job_dir}/${jobname}"
  $config_path        = "${job_dir}/config.xml"

  # Bring variables from Class['::jenkins'] into local scope.
  $cli_tries          = $::jenkins::cli_tries
  $cli_try_sleep   = $::jenkins::cli_try_sleep

  Exec {
    logoutput   => false,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
  }

  # Use Jenkins CLI to create the job
  $cat_config = "cat \"${tmp_config_path}\""
  $create_job = "${jenkins_cli} create-job \"${jobname}\""
  exec { "jenkins create-job ${jobname}":
    command => "${cat_config} | ${create_job}",
    creates => [$config_path, "${job_dir}/builds"],
    require => File[$tmp_config_path],
  }

  # Use Jenkins CLI to update the job if it already exists
  $update_job = "${jenkins_cli} update-job ${jobname}"
  exec { "jenkins update-job ${jobname}":
    command => "${cat_config} | ${update_job}",
    onlyif  => "test -e ${config_path}",
    unless  => "${difftool} ${config_path} ${tmp_config_path}",
    require => File[$tmp_config_path],
    notify  => Exec['reload-jenkins'],
  }

  # Deprecation warning if $enabled is set
  if $enabled != undef {
    warning("You set \$enabled to ${enabled}, this parameter is now deprecated, nothing will change whatever is its value")
  }
}
