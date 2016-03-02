# This private class manages Jenkins' config.xml
#
class jenkins::config::global {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { "${::jenkins::localstatedir}/config.xml":
    ensure  => file,
    content => $::jenkins::global_config,
    owner   => $::jenkins::user,
    group   => $::jenkins::group,
    mode    => '0644',
  }

}
