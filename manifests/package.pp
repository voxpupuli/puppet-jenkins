class jenkins::package($version = 'installed') {
  package {
    'jenkins' :
      ensure => $version;
  }
}

# Note:  Jenkins should install java, but it doesn't.  You may have to do it on your own.