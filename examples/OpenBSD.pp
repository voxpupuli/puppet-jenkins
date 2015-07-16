node default {

  package { 'jre':
    ensure => installed,
  }
  ->
  class {'::jenkins':
    install_java => false,
    repo         => false,
  }
  # Runs on Port 8000
}
