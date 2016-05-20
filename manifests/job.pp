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
#   template
#     path to a puppet template() resource containing the Jenkins XML job description
#     will override 'config' if set
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled
#     deprecated parameter (will have no effect if set)
#
#   ensure = 'present'
#     choose 'absent' to ensure the job is removed
#
#   difftool = '/usr/bin/diff -b-q'
#     Provide a command to execute to compare Jenkins job files
#
define jenkins::job(
  $config,
  $source   = undef,
  $template = undef,
  $jobname  = $title,
  $enabled  = undef,
  $ensure   = 'present',
  $difftool = '/usr/bin/diff -b -q',
){
  validate_string($config)
  if $source { validate_absolute_path($source) }
  if $template { validate_absolute_path($template) }
  validate_string($jobname)
  if $enabled != undef {
    warning("You set \$enabled to ${enabled}, this parameter is now deprecated, nothing will change whatever is its value")
  }
  validate_re($ensure, '^present$|^absent$')
  validate_string($difftool)

  include ::jenkins::cli

  Class['jenkins::cli'] ->
    Jenkins::Job[$title] ->
      Anchor['jenkins::end']

  if ($ensure == 'absent') {
    jenkins::job::absent { $title:
      jobname => $jobname,
    }
  } else {
    if $source {
      $realconfig = file($source)
    }
    elsif $template {
      $realconfig = template($template)
    }
    else {
      $realconfig = $config
    }

    jenkins::job::present { $title:
      config   => $realconfig,
      jobname  => $jobname,
      enabled  => $enabled,
      difftool => $difftool,
    }
  }

}
