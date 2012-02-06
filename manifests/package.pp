class jenkins::package {
  package {
    'jenkins' :
      ensure => installed;
  }
}

