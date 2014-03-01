# Class: jenkins::service
#
class jenkins::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'jenkins':
    ensure     => $jenkins::service_ensure,
    enable     => $jenkins::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

}

