# Class jenkins::cli_helper
#
# A helper script for creating resources via the Jenkins cli
#
class jenkins::cli_helper (
  $ssh_keyfile = undef,
){
  include ::jenkins
  include ::jenkins::cli

  $libdir = $::jenkins::libdir
  $cli_jar = $::jenkins::cli::jar

  if $::jenkins::config_hash and has_key($::jenkins::config_hash, 'HTTP_PORT') {
    $http_port = $::jenkins::config_hash['HTTP_PORT']
  } else {
    $http_port = '8080'
  }

  $helper_groovy = "${libdir}/puppet_helper.groovy"
  file {$helper_groovy:
    source  => 'puppet:///modules/jenkins/puppet_helper.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0444',
    require => Class['jenkins::cli'],
  }

  if $ssh_keyfile {
    $auth_arg = "-i ${ssh_keyfile}"
  } else {
    $auth_arg = ''
  }
  $helper_cmd = join([
    '/usr/bin/java',
    "-jar ${::jenkins::cli::jar}",
    "-s http://127.0.0.1:${http_port}",
    $auth_arg,
    "groovy ${helper_groovy}",
  ], ' ')
}
