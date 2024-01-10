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

  # in case of a cloudbees-folder element replace all '/' with underscore so only a file without subdirectory is deleted
  $replaced_jobname = regsubst($jobname, /\//, '_', 'G')
  $tmp_config_path  = "/tmp/${replaced_jobname}-config.xml"
  # in case of a cloudbees-folder element inserting sub-directory '/jobs' for every folder level so the existing config file is deleted
  $job_subdir_name  = regsubst($jobname, /\//, '/jobs/', 'G')
  $job_dir          = "${jenkins::job_dir}/${job_subdir_name}"
  $config_path      = "${job_dir}/config.xml"

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    ensure  => absent,
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
