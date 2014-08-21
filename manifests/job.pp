# Define: jenkins::job
#
#   This class create a new jenkins job given a name and config xml
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
#     whether to enable the job
#
#   ensure = 'present'
#     choose 'absent' to ensure the job is removed
#
define jenkins::job(
  $config,
  $jobname  = $title,
  $enabled  = 1,
  $ensure   = 'present',
){

  if ($ensure == 'absent') {
    jenkins::job::absent { $title:
      jobname => $jobname,
    }
  } else {
    jenkins::job::present { $title:
      config  => $config,
      jobname => $jobname,
      enabled => $enabled,
    }
  }

}
