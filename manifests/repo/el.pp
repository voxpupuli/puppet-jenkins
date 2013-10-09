# Class: jenkins::repo::el
#
class jenkins::repo::el inherits jenkins ()
{

  if $lts{
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat-stable/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
    }
  }

  else {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
    }
  }
}
