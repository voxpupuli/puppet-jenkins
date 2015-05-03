# Class: jenkins::repo::debian
#
class jenkins::repo::debian
{
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  include stdlib
  include apt

  if $::jenkins::lts  {
    apt::source { 'jenkins':
      location    => 'http://pkg.jenkins-ci.org/debian-stable',
      release     => 'binary/',
      repos       => '',
      key         => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      include_src => false,
    }
  }
  else {
    apt::source { 'jenkins':
      location    => 'http://pkg.jenkins-ci.org/debian',
      release     => 'binary/',
      repos       => '',
      key         => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      include_src => false,
    }
  }

  anchor { 'jenkins::repo::debian::begin': } ->
    Apt::Source['jenkins'] ->
    anchor { 'jenkins::repo::debian::end': }
}
