class jenkins::service {
  case $::operatingsystem {
    centos, redhat, oel: {
      service { 'jenkins':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }
    }
    # Stay as a no-op to preserve previous behavior
    default: { }
  }
}

