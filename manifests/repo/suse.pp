# Class: jenkins::repo::suse
#
class jenkins::repo::suse ( $lts=0 )
{

  include 'jenkins::repo'

  if $jenkins::repo::lts == 0 {
    zypprepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/opensuse/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
    }
  }
  elsif $jenkins::repo::lts == 1 {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/opensuse-stable/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
    }
  }

}

