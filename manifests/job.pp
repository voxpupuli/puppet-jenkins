# @summary Manage Jenkins jobs given a name and config xml
#
# @param config The content of the jenkins job config file (required)
# @param source Path to a puppet file() resource containing the Jenkins XML job description.
#     Will override 'config' if set
# @param template Path to a puppet template() resource containing the Jenkins XML job description.
#     Will override 'config' if set
# @param jobname the name of the jenkins job
# @param ensure choose 'absent' to ensure the job is removed
# @param difftool Provide a command to execute to compare Jenkins job files
# @param replace
#     Whether or not to replace the job if it already exists.
define jenkins::job (
  String $config,
  Optional[String] $source                  = undef,
  Optional[String[1]] $template             = undef,
  String $jobname                           = $title,
  Enum['present', 'absent'] $ensure         = 'present',
  String $difftool                          = '/usr/bin/diff -b -q',
  Boolean $replace                          = true
) {
  include jenkins::cli

  Class['jenkins::cli']
  -> Jenkins::Job[$title]
  -> Anchor['jenkins::end']

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
      difftool => $difftool,
      replace  => $replace,
    }
  }
}
