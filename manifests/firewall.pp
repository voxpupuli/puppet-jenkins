# @summary Integrate with the puppetlabs-firewall module for opening the port
#   to Jenkins automatically
# @api private
class jenkins::firewall {
  assert_private()

  firewall { '500 allow Jenkins inbound traffic':
    jump   => 'accept',
    state  => 'NEW',
    dport  => [jenkins_port()],
    proto  => 'tcp',
  }
}
