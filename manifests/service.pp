# Class: jenkins::service
#
class jenkins::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case $::osfamily  {
    'OpenBSD': {
        service { 'jenkins':
          ensure     => $jenkins::service_ensure,
          enable     => $jenkins::service_enable,
          provider   => $jenkins::service_provider,
          flags      => $jenkins::service_flags,
          hasstatus  => true,
          hasrestart => true,
        }
    }
    default: {
      service { 'jenkins':
        ensure     => $jenkins::service_ensure,
        enable     => $jenkins::service_enable,
        provider   => $jenkins::service_provider,
        hasstatus  => true,
        hasrestart => true,
      }
    }
  }

}
