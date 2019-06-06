# Class: jenkins::service
#
class jenkins::service {
  assert_private()

  service { 'jenkins':
    ensure     => $jenkins::service_ensure,
    enable     => $jenkins::service_enable,
    provider   => $jenkins::service_provider,
    hasstatus  => true,
    hasrestart => true,
  }

}
