# Class: jenkins::params
#
#
class jenkins::params {
  $version            = 'installed'
  $lts                = false
  $repo               = true
  $service_enable     = true
  $service_ensure     = 'running'
  $configure_firewall = true
  $install_java       = true
  $swarm_version      = '1.9'

  case $::osfamily {
  'Red Hat': {
    $slave_home = "/home/jenkins-slave"
    $service_file = "jenkins-slave.erb"
  }
  'Debian': {
    $slave_home = "/home/jenkins-slave"
    $service_file = "jenkins-slave-debian.erb"
  }
  'windows': {
    $slave_home = "${systemdrive}\\ProgramData\\jenkins-slave"
  }
  default: {
  }
}


