# Class: jenkins::repo::debian
#
class jenkins::repo::debian
{
  if $::jenkins::lts  {
    apt::source { 'jenkins':
      location    => 'http://pkg.jenkins-ci.org/debian-stable',
      release     => 'binary/',
      repos       => '',
      key         => 'D50582E6',
      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      include_src => false,
      }
    }
  else {
    apt::source { 'jenkins':
      location    => 'http://pkg.jenkins-ci.org/debian',
      release     => 'binary/',
      repos       => '',
      key         => 'D50582E6',
      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      include_src => false,
    }
  }
}



