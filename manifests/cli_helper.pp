# Class jenkins::cli_helper
#
# A helper script for creating resources via the Jenkins cli
#
# Parameters:
#
# ssh_keyfile = undef
#   Defaults to the value of $::jenkins::cli_ssh_keyfile. This parameter is
#   deprecated, please set $::jenkins::cli_ssh_keyfile instead of setting this
#   directly
#
class jenkins::cli_helper (
  Optional[Stdlib::Absolutepath] $ssh_keyfile = $::jenkins::cli_ssh_keyfile,
) {
  include ::jenkins
  include ::jenkins::cli

  Class['jenkins::cli']
    -> Class['jenkins::cli_helper']
      -> Anchor['jenkins::end']

  $libdir = $::jenkins::libdir
  $cli_jar = $::jenkins::cli::jar
  $port = jenkins_port()
  $prefix = jenkins_prefix()
  $helper_groovy = "${libdir}/puppet_helper.groovy"

  file { $helper_groovy:
    source  => 'puppet:///modules/jenkins/puppet_helper.groovy',
    owner   => $::jenkins::user,
    group   => $::jenkins::group,
    mode    => '0444',
    require => Class['jenkins::cli'],
  }

  if $ssh_keyfile != $::jenkins::cli_ssh_keyfile {
    info("Using jenkins::cli_helper(${ssh_keyfile}) is deprecated and will be removed in the next major version of this module")
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
