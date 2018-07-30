# Class: jenkins::repo::debian
#
class jenkins::repo::debian
{
  assert_private()

  include apt

  $pkg_host = 'https://pkg.jenkins.io'

  if $::jenkins::lts  {
    apt::source { 'jenkins':
      location => "${pkg_host}/debian-stable",
      release  => 'binary/',
      repos    => '',
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
        'source' => "${pkg_host}/debian/jenkins-ci.org.key",
      },
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
        'id'     => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
        'source' => "${pkg_host}/debian/jenkins-ci.org.key",
      },
    }
  }

  anchor { 'jenkins::repo::debian::begin': }
    -> Apt::Source['jenkins']
    -> anchor { 'jenkins::repo::debian::end': }
}
