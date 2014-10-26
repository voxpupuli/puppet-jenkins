#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::firewall {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::jenkins::config_hash and has_key($::jenkins::config_hash, 'HTTP_PORT') {
    $http_port = $::jenkins::config_hash['HTTP_PORT']
  } else {
    $http_port = '8080'
  }

  firewall { '500 allow Jenkins inbound traffic':
    action => 'accept',
    state  => 'NEW',
    dport  => [$http_port],
    proto  => 'tcp',
  }
}

