# Class: jenkins::cli
#
# Allow Jenkins commands to be issued from the command line
#
class jenkins::cli {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $jar = "${jenkins::libdir}/jenkins-cli.jar"
  $extract_jar = "jar -xf ${jenkins::libdir}/jenkins.war WEB-INF/jenkins-cli.jar"
  $move_jar = "mv WEB-INF/jenkins-cli.jar ${jar}"
  $remove_dir = 'rm -rf WEB-INF'

  exec { 'jenkins-cli' :
    command => "${extract_jar} && ${move_jar} && ${remove_dir}",
    path    => ['/bin', '/usr/bin'],
    cwd     => '/tmp',
    creates => $jar,
    require => Package['jenkins'],
  }
}
