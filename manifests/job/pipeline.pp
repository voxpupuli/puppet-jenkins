# jenkins::job::pipeline
#
# Configures a pipeline job. This job can be tied to a particular
# node and view using ssh credentials through login and password.
#
# Parâmetros:
# ===========
#
# view_config
#   Template path to job view. Default: jenkins/view.xml.erb.
#
# view_name
#   Name of the job view.
#
# job_config
#   The content of the jenkins job config file. Default:
#   jenkins/pipeline.xml.erb.
#
# job_name
#   the name of the jenkins job. Default: $title.
#
# groovy_script
#   Groovy script of the job.
#
# credentials_id
#   Credential id used to access the node. Default: $title.
#
# credentials_description
#   Extra info for credentials. Padrão: ''.
#
# credentials_username
#   Username of the credential used to access the node.
#   Default: vagrant.
#
# credentials_password
#   Password of the credential used to access the node.
#   Default: vagrant
#
# node_host
#   Host which runs the job.
#
# node_port
#   Host port. Default: 22.
#
# node_name
#   Name of the node with runs the job. Default: master.
#
# node_home
#   Home path of the node host. Default: /home/vagrant/.
#
# node_config
#   Template path to node config file.
#   Default: jenkins/config-sshnode.xml.erb (ssh).
#
define jenkins::job::pipeline (
  $view_config             = 'jenkins/view.xml.erb',
  $view_name               = undef,
  $job_config              = 'jenkins/pipeline.xml.erb',
  $job_name                = $title,
  $groovy_script           = undef,
  $credentials_id          = $title,
  $credentials_description = '',
  $credentials_username    = 'vagrant',
  $credentials_password    = 'vagrant',
  $node_host                = undef,
  $node_port                = '22',
  $node_name               = 'master',
  $node_home               = '/home/vagrant/',
  $node_config             = 'jenkins/config-sshnode.xml.erb'
) {

  jenkins::view::present { $view_name:
    config => $view_config
  } ->
  jenkins::job { $job_name:
    config   => template($job_config),
    viewname => $view_name
  }

  file { '/var/lib/jenkins/credentials.xml':
    ensure  => file,
    content => template('profiles/jenkins/credentials.xml.erb'),
    notify  => Service['jenkins']
  } ->
  jenkins::node::present { $node_name:
    config => template($node_config)
  }
}
