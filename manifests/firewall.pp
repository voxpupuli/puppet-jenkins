#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::firewall {
  if defined('::firewall') {
    firewall {
      '500 allow Jenkins inbound traffic':
        action => 'accept',
        state  => 'NEW',
        dport  => [8080],
        proto  => 'tcp',
    }
  }
}

