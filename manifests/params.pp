# @summary Default parameters
# @api private
class jenkins::params {
  $swarm_version = '2.2'
  $config_hash_defaults = {
    'JAVA_OPTS' => { value => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false' },
  }
  $default_plugins = [
    'bouncycastle-api', # required by instance-identity
    'credentials', # required by puppet_helper.groovy
    'instance-identity', # implied by structs
    'javax-activation-api', # implied by all plugin
    'javax-mail-api', # implied by all plugins
    'structs', # required by credentials plugin
  ]

  case $facts['os']['family'] {
    'Debian': {
      $repo                 = true
      $package_provider     = 'dpkg'
    }
    'RedHat': {
      $repo                 = true
      $package_provider     = 'rpm'
    }
    'Archlinux': {
      $repo                 = false
      $package_provider     = 'pacman'
    }
    default: {
      $repo                 = true
      $package_provider     = undef
    }
  }
}
