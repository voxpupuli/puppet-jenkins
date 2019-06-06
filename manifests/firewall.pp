#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::firewall {
  assert_private()

  firewall { '500 allow Jenkins inbound traffic':
    action => 'accept',
    state  => 'NEW',
    dport  => [jenkins_port()],
    proto  => 'tcp',
  }
}
