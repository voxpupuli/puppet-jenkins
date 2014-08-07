class jenkins::firewall ($firewall) {
  if ($firewall == 1) {
    firewall {
      '500 allow Jenkins inbound traffic':
        action => 'accept',
        state  => 'NEW',
        dport  => [8080],
        proto  => 'tcp',
    }
  }
}

