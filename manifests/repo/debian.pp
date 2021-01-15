# Class: jenkins::repo::debian
#
class jenkins::repo::debian
{
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include ::stdlib
  include ::apt

  $pkg_host = 'https://pkg.jenkins.io'
  $pkg_key_id = '62A9756BFD780C377CF24BA8FCEF32E745F2C3D5'
  $pkg_key_source = "${pkg_host}/debian/jenkins-io.key"

  ensure_packages(['apt-transport-https'])

  if $::jenkins::lts  {
    apt::source { 'jenkins':
      location => "${pkg_host}/debian-stable",
      release  => 'binary/',
      repos    => '',
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => "${pkg_key_id}",
        'source' => "${pkg_key_source}",
      },
      require  => Package['apt-transport-https'],
      notify   => Exec['apt_update'],
    }
  }
  else {
    apt::source { 'jenkins':
      location => "${pkg_host}/debian",
      release  => 'binary/',
      repos    => '',
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => "${pkg_key_id}",
        'source' => "${pkg_key_source}",
      },
      require  => Package['apt-transport-https'],
      notify   => Exec['apt_update'],
    }
  }

  anchor { 'jenkins::repo::debian::begin': }
    -> Apt::Source['jenkins']
    -> anchor { 'jenkins::repo::debian::end': }
}
