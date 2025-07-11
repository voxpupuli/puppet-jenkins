# @summary Removes a jenkins build job
# @api private
#
# @param jobname
#   the name of the jenkins job
#
define jenkins::job::absent (
  String $jobname = $title,
) {
  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $tmp_config_path  = "/tmp/${jobname}-config.xml"
  $job_dir          = "${jenkins::job_dir}/${jobname}"
  $config_path      = "${job_dir}/config.xml"

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    ensure => absent,
  }

  # Delete the job
  exec { "jenkins delete-job ${jobname}":
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "${jenkins::cli::cmd} delete-job \"${jobname}\"",
    logoutput => false,
    onlyif    => "test -f \"${config_path}\"",
    require   => Exec['jenkins-cli'],
  }
}
