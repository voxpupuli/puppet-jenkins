# @summary Configure the proxy part
# @api private
class jenkins::proxy {
  assert_private()

  # Bring variables from Class['jenkins'] into local scope.
  $proxy_host = $jenkins::proxy_host
  $proxy_port = $jenkins::proxy_port
  $no_proxy_list = $jenkins::no_proxy_list

  if $proxy_host and $proxy_port {
    # param format needed by puppet/archive
    $url = "http://${proxy_host}:${proxy_port}"
    $proxy_xml = "${jenkins::localstatedir}/proxy.xml"

    file { $proxy_xml:
      content => template('jenkins/proxy.xml.erb'),
      owner   => $jenkins::user,
      group   => $jenkins::group,
      mode    => '0644',
    }

    if $jenkins::manage_service {
      Package['jenkins']
      -> File[$proxy_xml]
      ~> Class['jenkins::service']
    } else {
      Package['jenkins']
      -> File[$proxy_xml]
    }
  } else {
    $url = undef
  }
}
