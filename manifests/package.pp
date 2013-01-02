class jenkins::package($version = 'installed') {
  package {
    'jenkins' :
      ensure => $version;
    'java-1.6.0-openjdk' :
      ensure => installed;
  }
}

