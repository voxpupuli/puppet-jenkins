node default {
  # Classify all nodes with the site specific jenkins class.
  class { 'jenkins': }
  group {
    'puppet' :
      ensure => present;
  }

  jenkins::plugin {
    'git' : ;
  }
}

# EOF
