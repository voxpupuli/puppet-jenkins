# Define: jenkins::windows::job::absent
#
#   Removes a jenkins build job
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   jobname = $title
#     the name of the jenkins job
#
define jenkins::windows::job::absent(
  $jobname  = $title,
){
  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }
  $jenkins_cli        = $jenkins::cli::cmd
  $tmp_config_path  = "C:/windows/temp/${jobname}-config.xml"
  $job_dir            = "${jenkins::params::libdir}/jobs/${jobname}"
  $config_path        = "${job_dir}/config.xml"

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    ensure  => absent,
  }

  # Delete the job
  exec { "jenkins delete-job ${jobname}":
    command   => "& ${jenkins_cli} delete-job \"${jobname}\"",
    logoutput => false,
    onlyif    => "if (test-path \"${config_path}\") {exit 0} else {exit 1}",
    require   => Exec['jenkins-cli'],
    provider  => powershell,
  }

}
