class jenkins::package($version = 'installed') {
  package {
    'jenkins' :
      ensure => $version;
  }
}

