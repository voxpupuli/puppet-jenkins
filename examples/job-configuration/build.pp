class jenkins::job::build(
  $config   = undef,
  $jobname  = $title,
  $enabled  = 1,
  $ensure   = 'present',
) {

  if $config == undef {
    $real_content = template('jenkins/job/build.xml.erb')
  } else {
    $real_content = $config
  }

  jenkins::job { 'build':
    config  => $real_content,
    jobname => $jobname,
    enabled => $enabled,
    ensure  => $ensure,
  }
}
