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

