# Class: jenkins::service
#
class jenkins::service {
  service { 'jenkins':
    ensure     => $jenkins::service_ensure,
    enable     => $jenkins::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
}

