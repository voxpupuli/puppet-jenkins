class jenkins::repo::el {
  File {
    owner => 'root',
    group => 'root',
    mode  => 0644,
  }
  yumrepo {'jenkins':
    descr    => 'Jenkins',
    baseurl  => 'http://pkg.jenkins-ci.org/redhat/',
    gpgcheck => 1,
	gpgkey   => "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
  }
}

