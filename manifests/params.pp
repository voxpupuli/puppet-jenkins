# Class: jenkins::params
#
#
class jenkins::params {
  $version                       = 'installed'
  $lts                           = false
  $repo                          = true
  $service_enable                = true
  $service_ensure                = 'running'
  $install_java                  = true
  $swarm_version                 = '1.9'

  $plugin_repository_base_url    = 'http://updates.jenkins-ci.org/download/plugins/'
  $plugin_repository_maven_style = false
  $default_plugin_group_id       = 'org.jenkins-ci.plugins'
}


