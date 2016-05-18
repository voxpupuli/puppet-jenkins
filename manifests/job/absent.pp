# Define: jenkins::job::absent
#
#   Removes a jenkins build job
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
define jenkins::job::absent(
  $jobname = $title,
){
  validate_string($jobname)

  include jenkins::cli
  
  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $tmp_config_path    = "$jenkins::cwd/${jobname}-config.xml"
  $job_dir            = "${::jenkins::job_dir}/${jobname}"
  $config_path        = "${job_dir}/config.xml"

   if $::osfamily == 'windows' {
    $onlyif     = "if (test-path \"${config_path}\") {exit 0} else {exit 1}"
  } else {
    $onlyif     = "test -f \"${config_path}\""
  }
  
  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    ensure  => absent,
  }

  # Delete the job
  exec { "jenkins delete-job ${jobname}":
    path      => $::jenkins::path,
    command   => "${jenkins::cli::cmd} delete-job \"${jobname}\"",
    logoutput => false,
    onlyif    => $onlyif,
    require   => Exec['jenkins-cli'],
  }

}
