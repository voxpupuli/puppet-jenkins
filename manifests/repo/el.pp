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
  }
  file { '/etc/yum/jenkins-ci.org.key':
    content => template("${module_name}/jenkins-ci.org.key"),
  }
  exec { 'rpm --import /etc/yum/jenkins-ci.org.key':
    path    => '/bin:/usr/bin',
    require => File['/etc/yum/jenkins-ci.org.key'],
    unless  => 'rpm -q gpg-pubkey-d50582e6-4a3feef6',
  }
}

