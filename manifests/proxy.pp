#
class jenkins::proxy {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/var/lib/jenkins/proxy.xml':
    content => template('jenkins/proxy.xml.erb'),
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644'
  }

}
