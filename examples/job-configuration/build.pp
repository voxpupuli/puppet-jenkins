# lint:ignore:autoloader_layout
class jenkins::job::build(
# lint:endignore
  $config   = undef,
  $jobname  = $title,
  $ensure   = 'present',
) {

  if $config == undef {
    $real_content = template('jenkins/job/build.xml.erb')
  } else {
    $real_content = $config
  }

  jenkins::job { 'build':
    ensure  => $ensure,
    jobname => $jobname,
    config  => $real_content,
  }
}
