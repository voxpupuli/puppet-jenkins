# Class: jenkins::params
#
#
class jenkins::params (){
  $version            = 'installed'
  $lts                = false
  $repo               = true
  $configure_firewall = true
  $install_java       = true
  $swarm_version      = '1.9'
}
