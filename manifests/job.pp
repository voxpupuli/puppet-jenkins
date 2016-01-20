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
#   enabled = true
#     whether to enable the job
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
  $enabled  = true,
  $ensure   = 'present',
  $difftool = '/usr/bin/diff -b -q',
){
  validate_string($config)
  if $source { validate_absolute_path($source) }
  if $template { validate_absolute_path($template) }
  validate_string($jobname)
  if ! is_bool($enabled) {
    warning("Passing non-boolean values to jenkins::job::enabled is deprecated-- ${enabled} is not a boolean")
    $real_enabled = num2bool($enabled)
  } else {
    $real_enabled = $enabled
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
      enabled  => $real_enabled,
      difftool => $difftool,
    }
  }

}
