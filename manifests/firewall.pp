#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::firewall(
  $port = 8080
) {
  firewall {
    '500 allow Jenkins inbound traffic':
      action => 'accept',
      state  => 'NEW',
      dport  => [$port],
      proto  => 'tcp',
  }
}

