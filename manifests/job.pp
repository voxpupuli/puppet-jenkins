# Define: jenkins::job
#
#   This class create a new jenkins job given a name and config xml
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   source
#     path to a puppet file() resource containing the Jenkins XML job description
#     will override 'config' if set
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled = true
#     whether to enable the job
#
#   ensure = 'present'
#     choose 'absent' to ensure the job is removed
#
define jenkins::job(
  $config,
  $source   = undef,
  $jobname  = $title,
  $enabled  = 1,
  $ensure   = 'present',
){

  if ($ensure == 'absent') {
    jenkins::job::absent { $title:
      jobname => $jobname,
    }
  } else {
    if $source {
      validate_string($source)
      $realconfig = file($source)
    }
    else {
      $realconfig = $config
    }

    jenkins::job::present { $title:
      config  => $realconfig,
      jobname => $jobname,
      enabled => $enabled,
    }
  }

}
