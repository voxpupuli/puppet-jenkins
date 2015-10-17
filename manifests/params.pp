# Class: jenkins::params
#
#
class jenkins::params {
  $version               = 'installed'
  $lts                   = false
  $repo                  = true
  $service_enable        = true
  $service_ensure        = 'running'
  $install_java          = true
  $swarm_version         = '1.22'
  $default_plugins_host  = 'https://updates.jenkins-ci.org'
  $port                  = '8080'
  $prefix                = ''
  $cli_tries             = 10
  $cli_try_sleep         = 10
  $package_cache_dir     = '/var/cache/jenkins_pkgs'
  $package_name          = 'jenkins'
  $localstatedir         = '/var/lib/jenkins'
  $localstatedir_type    = 'directory'
  $localstatedir_link    = undef

  $manage_user  = true
  $user         = 'jenkins'
  $manage_group = true
  $group        = 'jenkins'

  case $::osfamily {
    'Debian': {
      $libdir           = '/usr/share/jenkins'
      $package_provider = 'dpkg'
    }
    'RedHat': {
      $libdir           = '/usr/lib/jenkins'
      $package_provider = 'rpm'
    }
    default: {
      $libdir           = '/usr/lib/jenkins'
      $package_provider = false
    }
  }
}
