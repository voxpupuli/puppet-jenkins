# Define: jenkins::job::present
#
#   Creates or updates a jenkins build job
#
#   This define should be considered private.
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled = true
#     if the job should be enabled
#
define jenkins::job::present(
  $config,
  $jobname  = $title,
  $enabled  = true,
  $difftool = $::jenkins::difftool,
){
  validate_string($config)
  validate_string($jobname)
  validate_bool($enabled)
  validate_string($difftool)

  include jenkins::cli
  include jenkins::cli::reload

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli        = $jenkins::cli::cmd
  $tmp_config_path    = "$jenkins::cwd/${jobname}-config.xml"
  $job_dir            = "${::jenkins::job_dir}/${jobname}"
  $config_path        = "${job_dir}/config.xml"

  # Bring variables from Class['::jenkins'] into local scope.
  $cli_tries          = $::jenkins::cli_tries
  $cli_try_sleep   = $::jenkins::cli_try_sleep

  Exec {
    logoutput   => false,
    path        => $path,
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
    provider    => $jenkins::provider,
  }
  
  #Exec commands and different OS's are not easy to handle, 
  #the if windows logic is hard to avoid when there are this 
  #many commands to consider 
  if $::osfamily == 'windows' {
    $onlyifenable    = "if (test-path \"${config_path}\") {if ((get-content \"${config_path}\" | out-string) -inotlike \"<disabled>true\") {exit 0} else {exit 1}} else {exit 1}"
    $onlyifupdate     = "if (test-path \"${config_path}\") {exit 0} else {exit 1}"
    $onlyifdisable     = "if (test-path \"${config_path}\") {if ((get-content \"${config_path}\" | out-string) -inotlike \"<disabled>false\") {exit 0} else {exit 1}} else {exit 1}"
  } else {
    $onlyifenable     = "cat \"${config_path}\" | grep '<disabled>false'"
    $onlyifupdate     = "test -e \"${config_path}\""
    $onlyifdisable     = "cat \"${config_path}\" | grep '<disabled>true'"
  }
  $discommand = "${jenkins_cli} disable-job \"${jobname}\""
  $create_job = "${jenkins_cli} create-job \"${jobname}\""
  $update_job = "${jenkins_cli} update-job ${jobname}"
  $enbcommand = "${jenkins_cli} enable-job \"${jobname}\""
  $unless     = "${difftool} ${config_path} ${tmp_config_path}"
  $cat_config = "cat \"${tmp_config_path}\""
  $onlyif     = "${::jenkins::testpath} ${config_path}"
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
  }

  # Use Jenkins CLI to create the job
  exec { "jenkins create-job ${jobname}":
    command => "${cat_config} | ${create_job}",
    creates => [$config_path, "${job_dir}/builds"],
    require => File[$tmp_config_path],
  }

  # Use Jenkins CLI to update the job if it already exists
  exec { "jenkins update-job ${jobname}":
    command => "${cat_config} | ${update_job}",
    onlyif  => $onlyifupdate,
    unless  => "${difftool} '${config_path}' ${tmp_config_path}",
    require => File[$tmp_config_path],
    notify  => Exec['reload-jenkins'],
  }

  # Enable or disable the job (if necessary)
  if ($enabled) {
    exec { "jenkins enable-job ${jobname}":
      command => "${jenkins_cli} enable-job \"${jobname}\"",
      onlyif  => $onlyifenable,
      require => [
        Exec["jenkins create-job ${jobname}"],
        Exec["jenkins update-job ${jobname}"],
      ],
    }
  } else {
    exec { "jenkins disable-job ${jobname}":
      command => "${jenkins_cli} disable-job \"${jobname}\"",
      onlyif  => $onlyifdisable,
      require => [
        Exec["jenkins create-job ${jobname}"],
        Exec["jenkins update-job ${jobname}"],
      ],
    }
  }

}
