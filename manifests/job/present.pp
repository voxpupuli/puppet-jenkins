# @summary Creates or updates a jenkins build job
# @api private
#
# @param config The content of the jenkins job config file
# @param config_file Jenkins job config file (file on disk)
# @param jobname The name of the jenkins job
# @param replace Whether or not to replace the job if it already exists.
#
define jenkins::job::present (
  Optional[String] $config      = undef,
  Optional[String] $config_file = undef,
  String $jobname               = $title,
  String $difftool              = '/usr/bin/diff -b -q',
  Boolean $replace              = true,
) {
  include jenkins::cli
  include jenkins::cli::reload

  if $config_file and $config {
    fail('You cannot set both $config_file AND $config param, only one is required')
  }

  if $config_file == undef and $config == undef {
    fail('Please set one of $config_file or $config to create a job')
  }

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli        = $jenkins::cli::cmd
  if $config == undef {
    $tmp_config_path = $config_file
  }
  else {
    # in case of a cloudbees-folder element replace all '/' with underscore so only a file without subdirectory is created
    $replaced_jobname      = regsubst($jobname, /\//, '_', 'G')
    $tmp_config_path    = "/tmp/${replaced_jobname}-config.xml"
    #
    # When a Jenkins job is imported via the cli, Jenkins will
    # re-format the xml file based on its own internal rules.
    # In order to make job management idempotent, we need to
    # apply that formatting before the import, so we can do a diff
    # on any pre-existing job to determine if an update is needed.
    #
    # Jenkins likes to change single quotes to double quotes
    $a = regsubst($config, 'version=\'1.0\' encoding=\'UTF-8\'',
    'version="1.0" encoding="UTF-8"')
    # Change empty tags into self-closing tags
    $b = regsubst($a, '<([A-z]+)><\/\1>', '<\1/>', 'IG')
    # Change &quot; to " since Jenkins is weird like that
    $c = regsubst($b, '&quot;', '"', 'MG')
    # Change &apos; to ' since Jenkins is weird like that
    $d = regsubst($c, '&apos;', '\'', 'MG')

    # Temp file to use as stdin for Jenkins CLI executable
    file { $tmp_config_path:
      content => $d,
      require => Exec['jenkins-cli'],
      before  => Exec["jenkins create-job ${jobname}"],
    }
  }

  # in case of a cloudbees-folder element inserting sub-directory '/jobs' for every folder level so the existing config_path or job_dir/builds is found
  $job_subdir_name    = regsubst($jobname, /\//, '/jobs/', 'G')
  $job_dir            = "${jenkins::job_dir}/${job_subdir_name}"
  $config_path        = "${job_dir}/config.xml"

  # Bring variables from Class['jenkins'] into local scope.
  $cli_tries          = $jenkins::cli_tries
  $cli_try_sleep   = $jenkins::cli_try_sleep

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
  }

  if $replace {
    # Use Jenkins CLI to update the job if it already exists
    $update_job = "${jenkins_cli} update-job ${jobname}"
    exec { "jenkins update-job ${jobname}":
      command => "${cat_config} | ${update_job}",
      onlyif  => "test -e ${config_path}",
      unless  => "${difftool} ${config_path} ${tmp_config_path}",
      notify  => Exec['reload-jenkins'],
    }
  }
}
