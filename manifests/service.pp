# Class: jenkins::service
#
class jenkins::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ($::operatingsystem != 'Amazon')
  and (($::operatingsystem != 'Fedora' and versioncmp($::operatingsystemrelease, '7.0') >= 0)
  or  ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemrelease, '15') >= 0)) {
    service { 'jenkins':
      ensure     => $jenkins::service_ensure,
      enable     => $jenkins::service_enable,
      provider   => redhat,
      hasstatus  => true,
      hasrestart => true,
    }
  } else {
    service { 'jenkins':
      ensure     => $jenkins::service_ensure,
      enable     => $jenkins::service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
