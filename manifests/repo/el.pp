class jenkins::repo::el {
  File {
    owner => 0,
    group => 0,
    mode  => 0644,
  }
  file { '/etc/yum.repos.d/jenkins.repo':
    content => template("${module_name}/jenkins.repo"),
  }
  file { '/etc/yum/jenkins-ci.org.key':
    content => template("${module_name}/jenkins-ci.org.key"),
  }
  exec { 'rpm --import /etc/yum/jenkins-ci.org.key':
    path    => "/bin:/usr/bin",
    require => File['/etc/yum/jenkins-ci.org.key'],
    unless  => "rpm -q gpg-pubkey-d50582e6-4a3feef6",
  }
}

