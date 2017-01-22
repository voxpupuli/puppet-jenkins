#
class jenkins::proxy {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Bring variables from Class['::jenkins'] into local scope.
  $proxy_host = $::jenkins::proxy_host
  $proxy_port = $::jenkins::proxy_port
  $no_proxy_list = $::jenkins::no_proxy_list

  if $proxy_host and $proxy_port {

    # param format needed by puppet/archive
    $url = "http://${proxy_host}:${proxy_port}"
    $proxy_xml = "${::jenkins::localstatedir}/proxy.xml"

    file { $proxy_xml:
      content => template('jenkins/proxy.xml.erb'),
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      mode    => '0644',
    }

    Package['jenkins'] ->
    File[$proxy_xml] ~>
    Service['jenkins']

  } else {
    $url = undef
  }

}
