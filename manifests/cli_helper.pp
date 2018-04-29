# Class jenkins::cli_helper
#
# A helper script for creating resources via the Jenkins cli
#
class jenkins::cli_helper {
  include jenkins
  include jenkins::cli

  Class['jenkins::cli']
  -> Class['jenkins::cli_helper']
  -> Anchor['jenkins::end']

  $libdir = $jenkins::libdir
  $cli_jar = $jenkins::cli::jar
  $port = jenkins_port()
  $prefix = jenkins_prefix()
  $helper_groovy = "${libdir}/puppet_helper.groovy"

  file { $helper_groovy:
    source  => 'puppet:///modules/jenkins/puppet_helper.groovy',
    owner   => $jenkins::user,
    group   => $jenkins::group,
    mode    => '0444',
    require => Class['jenkins::cli'],
  }

  $helper_cmd = join(
    delete_undef_values([
      '/bin/cat',
      $helper_groovy,
      '|',
      '/usr/bin/java',
      "-jar ${::jenkins::cli::jar}",
      "-s http://127.0.0.1:${port}${prefix}",
      $::jenkins::_cli_auth_arg,
      'groovy =',
    ]),
    ' '
  )
}
