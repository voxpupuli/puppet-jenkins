node default {

  # Requires Module zleslie-pkgng

  Package {
    provider => 'pkgng',
  }

  package { 'openjdk':
    ensure => installed,
  }
  ->
  class {'::jenkins':
    install_java => false,
    repo         => false,
  }
  # Runs on Port 8180
}
