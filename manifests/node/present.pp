# Define: jenkins::node::present
#
#   Creates or updates a node
#
#   This define should be considered public.
#
# Parameters:
#
#   config
#     the content of the jenkins node config file (required)
#
#   node_name = $title
#     the name of the jenkins node
#
# Example (Using ssh-slaves plugin):
#
# 1. jenkins::node::present { 'node_name':
#      config => 'jenkins/config-sshnode.xml.erb'
#    }
#
# 2. jenkins::node::present { 'node':
#      node_name => 'node_name'
#      config    => 'jenkins/config-sshnode.xml.erb'
#    }
#
define jenkins::node::present (
  $config     = undef,
  $node_name  = $title,
) {
  validate_string($config)
  validate_string($node_name)

  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins nodes requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli     = $jenkins::cli::cmd
  $tmp_config_path = "/tmp/${title}-config.xml"
  $cat_config      = "cat \"${tmp_config_path}\""

  file { $tmp_config_path:
    content => $config,
    require => Exec['jenkins-cli'],
  }

  # Bring variables from Class['::jenkins'] into local scope.
  $cli_tries     = $::jenkins::cli_tries
  $cli_try_sleep = $::jenkins::cli_try_sleep

  Exec {
    logoutput   => false,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    tries       => $cli_tries,
    try_sleep   => $cli_try_sleep,
  }

  $create_node = "${jenkins_cli} create-node \"${node_name}\""
  exec { "jenkins create-node ${title}":
    command => "${cat_config} | ${create_node}",
    creates => ["${jenkins::localstatedir}/nodes/${node_name}"],
    require => File[$tmp_config_path]
  }

  $update_node = "${jenkins_cli} update-node ${node_name}"
  exec { "jenkins update-node ${title}":
    command => "${cat_config} | ${update_node}",
    onlyif  => "test -e ${jenkins::localstatedir}/nodes/${node_name}/config.xml",
    require => File[$tmp_config_path],
    notify  => Exec['reload-jenkins']
  }
}
