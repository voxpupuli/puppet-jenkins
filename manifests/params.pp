# Class: jenkins::params
#
#
class jenkins::params {
  $version            = 'installed'
  $lts                = 'false'
  $repo               = 'true'
  $service_enable     = 'true'
  $service_ensure     = 'running'
  $configure_firewall = 'true'
  $install_java       = 'true'
  $swarm_version      = '1.9'
}


