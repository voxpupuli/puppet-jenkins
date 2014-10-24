# Class: jenkins::params
#
#
class jenkins::params {
  $version                    = 'installed'
  $lts                        = false
  $repo                       = true
  $service_enable             = true
  $service_ensure             = 'running'
  $install_java               = true
  $swarm_version              = '1.17'
  $default_plugins_host       = 'http://updates.jenkins-ci.org'
  $port                       = '8080'

  case $::osfamily {
    'Debian': {
      $libdir = '/usr/share/jenkins'
    }
    default: {
      $libdir = '/usr/lib/jenkins'
    }
  }
}


