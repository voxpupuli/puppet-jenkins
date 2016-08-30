# Define: jenkins::node::absent
#
#   Removes a node
#
#   This define should be considered public.
#
# Parameters:
#
#   node_name = $title
#     the name of the jenkins node
#
# Example:
#
# 1. jenkins::node::absent { 'node_name': }
#
define jenkins::node::absent (
  $node_name = $title
) {
  validate_string($node_name)

  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins nodes requires \$jenkins::service_ensure to be set to \'running\'')
  }

  exec { "jenkins delete-node ${node_name}":
    path      => ['/usr/bin', '/usr/sbin', '/bin'],
    command   => "${jenkins::cli::cmd} delete-node \"${node_name}\"",
    logoutput => false,
    onlyif    => "${jenkins::cli::cmd} get-node \"${node_name}\"",
    require   => Exec['jenkins-cli']
  }
}
