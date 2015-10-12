#
class jenkins::proxy {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Bring variables from Class['::jenkins'] into local scope.
  $proxy_host = $::jenkins::proxy_host
  $proxy_port = $::jenkins::proxy_port
  $no_proxy_list = $::jenkins::no_proxy_list

  file { "${::jenkins::localstatedir}/proxy.xml":
    content => template('jenkins/proxy.xml.erb'),
    owner   => $::jenkins::user,
    group   => $::jenkins::group,
    mode    => '0644'
  }

}
