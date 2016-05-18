#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::firewall {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ($::operatingsystem == 'windows')  {
    fail("Firewall does not support windows. Set firewall to false")
  }
  firewall { '500 allow Jenkins inbound traffic':
    action => 'accept',
    state  => 'NEW',
    dport  => [jenkins_port()],
    proto  => 'tcp',
  }
}
